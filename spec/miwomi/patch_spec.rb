require 'miwomi/patch'

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
      double "Block: #{name} (#{id})", id: id, name: name
    end

    it 'detects blocks with same name' do
      from << block(23, 'Stone')
      from << block(1,  'Dirt')
      to   << block(42, 'Stone')
      to   << block(2,  'Dirt')
      should translate_id(23).to(42)
      should translate_id(1).to(2)
    end
  end
end
