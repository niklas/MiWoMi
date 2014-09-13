require 'spec_helper'

describe Miwomi::Finder do

  context '.insert' do

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

  end

end
