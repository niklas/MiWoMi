require 'spec_helper'

describe Miwomi::Finder do

  context '.insert' do
    before do
      described_class.undefine_all
    end

    it 'defines and inserts a new class inheriting from Miwomi::Finder' do
      expect {
        described_class.insert {}
      }.to change { described_class.all.count }.from(0).to(1)

      f = described_class.all.first
      f.should < described_class
    end

    it 'allows to define instance methods in provided block' do
      k = described_class.insert do
        def foo
          23
        end
      end

      k.new.foo.should == 23
    end

    it 'has the name set by the file defined in' do
      k = described_class.insert {}
      k.name.should == 'Miwomi::Finder::FinderSpec'
    end

    context 'DSL' do
      it 'can define words' do
        k = described_class.insert do
          words { |source| source.split }
        end

        f = k.new
        f.stub source: 'foo bar'
        f.words.should == ['foo', 'bar']
      end
    end

  end

end
