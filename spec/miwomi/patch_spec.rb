require 'spec_helper'

RSpec::Matchers.define :translate_id do |from_id|
  match do |patch|
    raise(ArgumentError, "please give a .to()") unless @to_id

    patch.apply
    @translation = patch.translations.find { |t| t.from.id == from_id }
    @translation && @translation.to.id == @to_id
  end

  chain :to do |to_id|
    @to_id = to_id
  end

  failure_message_for_should do |patch|
    if @translation
      "should translate #{from_id} to #{@to_id}, but did to #{@translation.to.id}"
    else
      "could not find a translation for id: #{from_id}"
    end
  end

  failure_message_for_should_not do |patch|
    if @translation
      "expected to not translate #{from_id}, but translated to #{@translation.to.id}"
    else
      "erm"
    end
  end
end

RSpec::Matchers.define :fail_translating do |from_id|
  match do |patch|
    raised = false
    begin
      patch.apply
    rescue Miwomi::Patch::Error => e
      raised = e
    end

    raised
  end
end

RSpec::Matchers.define :translate_nothing do
  match do |patch|
    patch.apply
    @translations = patch.translations
    @translations.empty?
  end

  failure_message_for_should do |patch|
    "should not translate anything, but did:\n#{@translations.map(&:to_midas).join("\n")}"
  end
end

describe Miwomi::Patch do
  let(:options) { described_class.default_opts }
  subject { described_class.new from, to, options }
  let(:from) { collection }
  let(:to)   { collection }

  describe '.new' do
    it 'takes two collections and options' do
      expect { subject }.not_to raise_error

      subject.from.should == from
      subject.to.should == to
      subject.options.should == options
    end

    it 'has optional options'
  end

  describe '#apply' do
    def block(id, name)
      Miwomi::Block.new(id, name)
    end

    def item(id, name)
      Miwomi::Item.new(id, name)
    end

    describe 'exact name matching' do
      it 'detects blocks with exactly matching name' do
        from << block(23, 'Stone')
        from << block(1,  'Dirt')
        to   << block(42, 'Stone')
        to   << block(2,  'Dirt')
        should translate_id(23).to(42)
        should translate_id(1).to(2)
      end

      it 'detects block with matching name ignoring case' do
        from << block(23, 'tile.BlockDetector')
        to   << block(42, 'tile.blockDetector')
        to   << block(666, 'tile.another.blockDetector')
        should translate_id(23).to(42)
      end

      it 'detects items with exactly matching name' do
        from << item(23, 'Shovel')
        from << item(1,  'Pickaxe')
        to   << item(42, 'Shovel')
        to   << item(2,  'Pickaxe')
        should translate_id(23).to(42)
        should translate_id(1).to(2)
      end

      describe 'given alternatives' do
        it 'detects items with renamed i18n scopes' do
          options.alternatives << ['rc.liquid', 'railcraft.fluid']
          from << item(7770, 'item.rc.liquid.creosote.bottle')

          to   << item(7783, 'item.railcraft.fluid.creosote.bottle')
          to   << item(7789, 'item.railcraft.fluid.steam.bottle')
          to   << item(7784, 'item.railcraft.fluid.creosote.bucket')
          should translate_id(7770).to(7783)
        end
      end
    end

    describe 'substring matching' do
      it 'finds simple match' do
        from << block(250, 'tile.oreCopper')
        to << block(623, 'blockOreCopper')
        to << block(2, 'tile.dirt')
        to << block(3, 'tile.stone')
        should translate_id(250).to(623)
      end

      it 'rejects ambigous match' do
        from << block(250, 'tile.oreCopper')
        to << block(1, 'tile.somethingElse')
        to << block(3, 'tile.stone')

        should fail_translating
      end

      it 'resolves ambiguous match when one has fitting id' do
        from << block(600, 'tile.blockAlloy')
        to << block(600, 'blockAlloy')
        to << block(601, 'blockAlloyGlass')

        should translate_nothing # is kept
      end
    end

    it 'does not mention keeps' do
      from << block(1, 'Stone')
      to << block(1, 'Stone')
      should translate_nothing
    end

    describe 'NEI not dumping vanilla items by name' do
      it 'skips item when lookes like badly dropped' do
        from << item(256, 'item.shovelIron')
        to << block(256, 'tile.ForgeFiller')
        should translate_nothing
      end

      it 'skips item even if there are substring alternatives' do
        from << item(256, 'item.apple')
        to << block(256, 'tile.ForgeFiller')
        to << block(13795, 'item.cratedApples')
        to << block(14363, 'item.tconstruct.apple.diamond')
        should translate_nothing
      end
    end

    it 'does not try to translate block to item' do
      from << block(1, 'Stone')
      to   << item(2, 'Stone')
      should fail_translating
    end

    it 'complains when a translation could not be found' do
      from << block(1, 'Stone')
      should fail_translating
    end

    it 'ignores vanilla technical blocks' do
      from << block(34, 'PistonHead')
      to   << block(77,  'PistonHead')
      should_not translate_id(34).to(77)
    end

    it 'drops blocks by name from list' do
      from << block(100, 'com.eloraam.redpower.world.BlockCustomCrops')
      options.drop = ['eloraam.redpower']
      should translate_id(100).to(0)
    end

    it 'drops blocks by id' do
      from << block(100, 'Fnords')
      options.drop_ids = [23,100]
      expect { subject }.to_not raise_error
      should translate_id(100).to(0)
    end
  end

  describe '#to_midas' do
    it 'produces string used as a patch for mIDas gold' do
      a = double 'Translation A', to_midas: 'AA'
      b = double 'Translation B', to_midas: 'BB'
      c = double 'Translation C', to_midas: 'CC'
      subject.stub translations: [a,b,c]
      subject.to_midas.should == "AA\nBB\nCC"
    end
  end

  describe '#output_filename' do
    it 'is generated automatically' do
      subject.stub from: %w(bar), to: %w(foo)
      subject.output_filename.should =~ /^\w{40}\.midas$/
    end
    it 'can be specified' do
      name = 'exactly_here.mamamidas'
      options.output_filename = name
      subject.output_filename.should == name
    end
  end

  context 'save & resume' do
    let(:path) { File.expand_path('../../../tmp/progess.yml', __FILE__) }
    before { FileUtils.mkdir_p File.basename(path) }
    after  { FileUtils.rm_f path }
    let(:content) { File.read path }

    let(:from) { collection(from1, from2, kept, todo) }
    let(:to)   { collection(to2, to1) }

    let(:todo)  { thing id: 666, name: 'Beast' }
    let(:from1) { thing id: 23, name: 'Water' }
    let(:from2) { thing id: 17, name: 'Knowlege' }
    let(:to1)   { thing id: 42, name: 'Wine' }
    let(:to2)   { thing id: 23, name: 'Fear' }

    let(:kept)  { thing id: 9001, name: 'Spirit' }

    before do
      subject.options.progress_path = path
      subject.options.keep_ids = [kept.id]
      subject.stub(:find_match).with(from1) { to1 }
      subject.stub(:find_match).with(from2) { to2 }
      subject.stub(:find_match).with(todo) { nil }
      expect { subject.apply }.to raise_error(Miwomi::Patch::NoMatchFound)
    end

    context '#apply' do
      it 'saves as yaml' do
        content.should_not be_blank
        parsed = YAML.load(content)
        parsed.should be_hash_matching(
          'translations' => [
            { 'from' => 23, 'to' => 42 },
            { 'from' => 17, 'to' => 23 },
          ],
          'keeps' => [9001],
        )
      end

      context 'resuming' do
        let(:subject2) { described_class.new from, to, options }
        before do
          subject2.options.progress_path = path
        end

        let(:trs) { subject2.translations }
        let(:keeps) { subject2.keeps }

        it 'loads existing progress' do
          trs.should have(2).items
          trs[0].from.should == from1
          trs[0].to.should == to1
          trs[1].from.should == from2
          trs[1].to.should == to2
          keeps.should include(kept)
        end

        context '#apply' do
          it 'resumes where saved' do
            subject2.should_not_receive(:find_match).with(from1)
            subject2.should_not_receive(:find_match).with(from2)
            subject2.should_receive(:find_match).with(todo) { nil }
            expect { subject2.apply }.to raise_error(Miwomi::Patch::NoMatchFound)
          end
        end
      end
    end

    context '#already_processed?' do
      it 'is true when translated' do
        subject.should have_already_processed(from1)
      end
      it 'is true when kept' do
        subject.should have_already_processed(kept)
      end
      it 'else is false' do
        subject.should_not have_already_processed(todo)
      end
    end
  end
end
