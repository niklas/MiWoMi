require 'spec_helper'

describe Miwomi::Matcher do
  def t(attrs={})
    double('NamedThing', {id: attrs.object_id}.merge(attrs))
  end

  let(:source) { t() }
  subject { described_class.new source }

  it 'has a source' do
    subject.source.should_not be_nil
  end

  context '#run' do
    subject { described_class.new source, finders: finders }
    let(:found) { double 'Finder', internal_name: 'even', results: [t(id: 2),t(id: 4),t(id: 6)]}
    let(:not_found) { double 'Finder' , internal_name: 'counting', results: [t(id: 1),t(id: 2),t(id: 3)]}
    let(:finders) { [found, not_found, found] }
    it 'goes through all finders and records candidates' do
      expect { subject.run }.to change { subject.candidates.length }.from(0).to(2)
    end
  end

end
