require 'spec_helper'

describe Miwomi::Translation do
  context '#to_midas' do
    let(:from) { double('FromBlock').as_null_object }
    let(:to)   { double('ToBlock').as_null_object }
    subject { described_class.new from, to }
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

  context '#to_yaml' do
    subject { described_class.new from, to }
    let(:from) { thing id: 23, name: "Water" }
    let(:to)   { thing id: 42, name: "Wine" }

    it 'serializes to YAML' do
      yaml = subject.to_yaml
      back = YAML.load(yaml)

      back.should == {
        'from' => 23, 'to' => 42
      }
    end
  end

  context '.from_yaml' do
    let(:froms) { collection(from1, from2) }
    let(:tos)   { collection(to2, to1) }

    let(:from1) { thing id: 23, name: 'Water' }
    let(:from2) { thing id: 17, name: 'Knowlege' }
    let(:to1)   { thing id: 42, name: 'Wine' }
    let(:to2)   { thing id: 23, name: 'Fear' }

    let(:source)  { [
      { 'from' => 23, 'to' => 42 }, # water to wine
      { 'from' => 17, 'to' => 23 }, # knowledge brings fear
    ]}

    let(:yaml) { source.to_yaml }

    subject { described_class.from_yaml yaml, froms, tos }

    let(:first)  { subject.first }
    let(:second) { subject[1] }

    it 'finds "from" blocks from supplied collection' do
      first.from.should == from1
      second.from.should == from2
    end

    it 'finds "to" blocks from supplied collection' do
      first.to.should == to1
      second.to.should == to2
    end

    it 'fails when "from" block is not loaded' do
      source[0]['from'] = 66
      expect { subject }.to raise_error
    end

    it 'fails when "to" block is not loaded' do
      source[0]['to'] = 66
      expect { subject }.to raise_error
    end
  end
end
