require 'miwomi'

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
    patch.apply if patch.translations.nil?
    patch.translations.empty?
  end
end

describe Miwomi::Patch do
  describe '.new' do
    let(:from) { double 'FromCollection' }
    let(:to)   { double 'ToCollection' }
    subject { described_class.new from, to }

    it 'takes two collections' do
      expect { subject }.not_to raise_error

      subject.from.should == from
      subject.to.should == to
    end
  end

  describe '#apply' do
    let(:from) { [] }
    let(:to)   { [] }
    subject { described_class.new from, to }
    def block(id, name)
      Miwomi::Block.new(id, name)
    end

    def item(id, name)
      Miwomi::Item.new(id, name)
    end

    it 'detects blocks with exactly matching name' do
      from << block(23, 'Stone')
      from << block(1,  'Dirt')
      to   << block(42, 'Stone')
      to   << block(2,  'Dirt')
      should translate_id(23).to(42)
      should translate_id(1).to(2)
    end

    it 'detects items with exactly matching name' do
      from << item(23, 'Shovel')
      from << item(1,  'Pickaxe')
      to   << item(42, 'Shovel')
      to   << item(2,  'Pickaxe')
      should translate_id(23).to(42)
      should translate_id(1).to(2)
    end

    it 'finds match by matching substrings' do
      from << block(250, 'tile.oreCopper')
      to << block(623, 'blockOreCopper')
      to << block(2, 'tile.dirt')
      to << block(3, 'tile.stone')
      should translate_id(250).to(623)
    end

    it 'rejects ambigous match for substrings' do
      from << block(250, 'tile.oreCopper')
      to << block(1, 'tile.somethingElse')
      to << block(3, 'tile.stone')

      should fail_translating
    end

    describe 'NEI not dumping vanilla items by name' do
      before :each do
        from << item(256, 'item.shovelIron')
      end
      it 'skips item when lookes like badly dropped' do
        to << block(256, 'tile.ForgeFiller')
        should translate_nothing
      end
    end

    it 'complains when translatiing block to id' do
      from << block(1, 'Stone')
      to   << item(2, 'Stone')
      expect { subject.apply }.to raise_error(Miwomi::Patch::IncompatibeType)
    end

    it 'complains when a translation could not be found' do
      from << block(1, 'Stone')
      expect { subject.apply }.to raise_error(Miwomi::Patch::NoMatchFound)
    end

    it 'ignores vanilla technical blocks' do
      from << block(34, 'PistonHead')
      to   << block(77,  'PistonHead')
      should_not translate_id(34).to(77)
    end

    def options(o)
      described_class.default_opts.tap do |defaults|
        o.each do |k,v|
           defaults[k] = v
        end
      end
    end

    it 'ignores blocks by name from list' do
      from << block(100, 'com.eloraam.redpower.world.BlockCustomCrops')
      subject.apply options(ignore: ['eloraam.redpower'])
      should translate_nothing
    end

    it 'ignores blocks by id' do
      from << block(100, 'Fnords')
      expect {
        subject.apply options(ignore_ids: [23,100])
      }.to_not raise_error
      should translate_nothing
    end
  end

  describe '#to_midas' do
    it 'produces string used as a patch for mIDas gold'
  end
end
