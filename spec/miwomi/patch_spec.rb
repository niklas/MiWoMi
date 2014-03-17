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
    it 'can change a single Block id'
    it 'can change a single Item id'
    it 'complains when changing Block into Item'
    it 'complains when changing Item into Block'
    it 'can change 3 out of 7 needed ids'
    it 'does not touch 4 out of 7 unchanged ids'
    it 'can resolve chain of 2'
    it 'can resolve chain of 3'
    it 'can resolve chain of 7'
    it 'can resolve swap (circle of 2)'
    it 'can resolve circle of 3'
    it 'can resolve circle of 7'
  end
end
