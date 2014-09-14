require 'spec_helper'

describe Miwomi::Matcher do
  let(:source) { double 'NamedThing' }
  subject { described_class.new source }

  it 'has a source' do
    subject.source.should_not be_nil
  end

  context '#run' do
    subject { described_class.new source, finders: finders }
    let(:found) { double 'Finder' }
    let(:not_found) { double 'Finder' }
    let(:finders) { [found, not_found, found] }
    it 'goes through all finders and records candidates' do
      expect { subject.run }.to change { subject.candidates.count }.from(0).to(2)
    end
  end

end
