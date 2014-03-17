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

    it 'complains when translatiing block to id' do
      from << block(1, 'Stone')
      to   << item(2, 'Stone')
      expect { subject.apply }.to raise_error
    end
  end

  describe '#to_midas' do
    it 'produces string used as a patch for mIDas gold'
  end
end
