require 'spec_helper'

describe Miwomi::Matcher do
  def t(id=nil,attrs={})
    double('NamedThing', {id: id || attrs.object_id, to_s: id}.merge(attrs))
  end
  let(:a) { t('a') }
  let(:b) { t('b') }
  let(:c) { t('c') }
  let(:d) { t('d') }
  let(:e) { t('e') }
  let(:f) { t('f') }


  let(:source) { t() }
  subject { described_class.new source }

  it 'has a source' do
    subject.source.should_not be_nil
  end

  context '#run' do
    subject { described_class.new source, finders: finders }
    let(:found) { double 'Finder', internal_name: 'even', results: [b, d, f]}
    let(:found_other) { double 'Finder' , internal_name: 'counting', results: [a,b,c]}
    let(:finders) { [found, found_other, found] }
    it 'goes through all finders and records candidates' do
      expect { subject.run }.to change { subject.candidates.length }.from(0).to(5) # all but 'e'

      cands = subject.candidate_by_result
      cands[a].weight.should == 1
      cands[b].weight.should == 3
      cands[c].weight.should == 1
      cands[d].weight.should == 2
      cands[e].should be_nil
      cands[f].weight.should == 2
    end
  end


  context '#candidates' do
    def found!(fi,r,w=1)
      subject.send :found!, fi, r, w
    end

    before :each do
      found! 'Z', a, 10
      found! 'Z', b
      found! 'Z', c
      found! 'Y', b
      found! 'Y', d
      found! 'Y', e
      found! 'Z', b
      found! 'Z', d
      found! 'Z', f
    end

    context '#weighted_candidates' do
      it "just counts the candidates' occurrences" do
        subject.weighted_candidates(true).should be_hash_matching(
          a => 10,
          b => 3,
          d => 2,
          c => 1,
          e => 1,
          f => 1,
        )
        # sorting is lost on rehashing
      end

      it "considers the weight of the recorded match"
    end

    context '#write_candidates_hint' do
      it 'lists the top 5 candidates' do
        x = ['OK go']
        subject.write_candidates_hint(x)
        x[0].should == 'OK go'
        x[1].should == 'best candidates:'
        x[2].should == '   10: a'
        x[3].should == '    3: b'
        x[4].should == '    2: d'
        x[5].should == '    1: c'
        x[6].should == '    1: e' # sort of random...
        x[7].should be_nil
      end
    end
  end

end
