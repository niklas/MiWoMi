require 'miwomi/patch'

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
