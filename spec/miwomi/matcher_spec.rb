require 'spec_helper'

describe Miwomi::Matcher do
  let(:a) { thing('a') }
  let(:b) { thing('b') }
  let(:c) { thing('c') }
  let(:d) { thing('d') }
  let(:e) { thing('e') }
  let(:f) { thing('f') }


  let(:source) { thing() }
  subject { described_class.new source }

  it 'has a source' do
    subject.source.should_not be_nil
  end

  context '#run' do
    subject { described_class.new source, finders: finders }
    let(:found) { finder internal_name: 'even', results: [b, d, f]}
    let(:found_other) { finder internal_name: 'counting', results: [a,b,c]}
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

      subject.candidates.each do |candidates|
        candidates.finders.should_not be_empty
      end
    end
  end


  context '#candidates' do
    def found!(fi,r,w=1)
      subject.send :found!, fi, r, w
    end
    let(:z) { finder weight: 1 }
    let(:y) { finder weight: 1 }
    let(:x) { finder weight: 3 }

    before :each do
      found! z, a, 10
      found! z, b
      found! z, c
      found! y, b
      found! y, d
      found! y, e
      found! x, b
      found! x, d
      found! x, f
    end

    context '#weighted_candidates' do
      def gna(thing)
        subject.candidate_by_result[thing]
      end
      it "just counts the candidates' occurrences" do
        subject.weighted_candidates(true).should be_hash_matching(
          gna(a) => 10,
          gna(b) => 5,
          gna(d) => 4,
          gna(c) => 1,
          gna(e) => 1,
          gna(f) => 3,
        )
        # sorting is lost on rehashing
      end

      it "considers the weight of the recorded match"
    end

    context '#write_candidates_hint' do
      it 'lists the top 5 candidates' do
        x = ['OK go']
        subject.write_candidates_hint(x)
        x[0].should  == 'OK go'
        x[1].should  == 'top 5 candidates:'
        x[2].should  == '{1}   10: a'
        x[4].should  == '{2}    5: b'
        x[6].should  == '{3}    4: d'
        x[8].should  == '{4}    3: f'
        x[10].should == '{5}    1: e' # sort of random...
        x[12].should be_nil
      end
    end
  end

end
