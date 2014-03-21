require 'miwomi'

describe Miwomi::Patch::Translation do
  let(:from) { double('FromBlock').as_null_object }
  let(:to)   { double('ToBlock').as_null_object }
  subject { described_class.new from, to }
  context '#to_midas' do
    it 'produces readable format for mIDas' do
      from.stub id: 23
      to.stub id: 42
      subject.to_midas.should =~ /^23 -> 42$/
    end
    it 'comments using names' do
      from.stub name: 'Iron'
      to.stub name: 'Pudding'
      subject.to_midas.should =~ /^# Iron => Pudding$/
    end
  end

end

