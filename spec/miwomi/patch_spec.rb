require 'miwomi/patch'

RSpec::Matchers.define :translate_id do |from|
  match do |patch|
    raise(ArgumentError, "please give a .to()") unless @to
    @translation = patch.translations.find { |t| t.from == from }
    @translation && @translation.to == @to
  end

  chain :to do |to|
    @to = to
  end

  failure_message_for_should do |patch|
    if @translation
      "should translate #{from} to #{@to}, but targets #{@translation.to}"
    else
      "could not find a translation for id: #{from}"
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
