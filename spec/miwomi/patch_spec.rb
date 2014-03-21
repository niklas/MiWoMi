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
    patch.apply
    patch.translations.empty?
  end
end

describe Miwomi::Patch do
  let(:options) { described_class.default_opts }
  subject { described_class.new from, to, options }

  describe '.new' do
    let(:from) { double 'FromCollection' }
    let(:to)   { double 'ToCollection' }

    it 'takes two collections and options' do
      expect { subject }.not_to raise_error

      subject.from.should == from
      subject.to.should == to
      subject.options.should == options
    end

    it 'has optional options'
  end

  describe '#apply' do
    let(:from) { Miwomi::Collection.new }
    let(:to)   { Miwomi::Collection.new }
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

        should translate_id(600).to(600)
      end
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

    it 'ignores blocks by name from list' do
      from << block(100, 'com.eloraam.redpower.world.BlockCustomCrops')
      options.ignore = ['eloraam.redpower']
      should translate_nothing
    end

    it 'ignores blocks by id' do
      from << block(100, 'Fnords')
      options.ignore_ids = [23,100]
      expect { subject }.to_not raise_error
      should translate_nothing
    end
  end

  describe '#to_midas' do
    it 'produces string used as a patch for mIDas gold'
  end
end
