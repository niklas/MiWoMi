require 'spec_helper'

describe Miwomi::Translation do
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
end
