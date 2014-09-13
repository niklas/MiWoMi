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

  end

end
