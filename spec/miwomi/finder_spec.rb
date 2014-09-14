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

    it 'can override the name' do
      k = described_class.insert(name: 'special_sauce') {}
      k.name.should == 'Miwomi::Finder::SpecialSauce'
    end

    it 'can define position with :after' do
      described_class.insert(name: 'plate') {}
      described_class.insert(name: 'lower_patty') {}
      described_class.insert(name: 'top_patty') {}
      described_class.insert(name: 'beef', after: 'lower_patty') {}

      described_class.all.map(&:internal_name).should == %w(plate lower_patty beef top_patty)
    end

    it 'can define position with :before' do
      described_class.insert(name: 'plate') {}
      described_class.insert(name: 'lower_patty') {}
      described_class.insert(name: 'top_patty') {}
      described_class.insert(name: 'beef', before: 'top_patty') {}

      described_class.all.map(&:internal_name).should == %w(plate lower_patty beef top_patty)
    end

    context 'DSL' do
      it 'can define words' do
        f = described_class.insert do
          words { |source| source.split }
        end.new

        f.stub source: double(name: 'foo bar')
        f.words.should == ['foo', 'bar']
        f.should have_words
      end

      it 'can define attribute to call on candidates and source' do
        f = described_class.insert do
          attribute :kloss
        end.new

        f.candidate_attribute.should == :kloss
        f.source_attribute.should == :kloss
      end

      it 'can define attribute to call on candidates only' do
        f = described_class.insert do
          candidate_attribute :kloss
        end.new

        f.candidate_attribute.should == :kloss
        f.source_attribute.should == :name
      end

      it 'can define attribute to call on source only' do
        f = described_class.insert do
          source_attribute :kloss
        end.new

        f.candidate_attribute.should == :name
        f.source_attribute.should == :kloss
      end

      it 'can define how words are matched' do
        f = described_class.insert do
          match_word do |w,v|
            w == v.downcase
          end
        end.new

        f.should be_word_matches_value('x', 'X')
      end

      it 'can match the pure attributes' do # for customization
        f = described_class.insert do
          match_value do |w,v|
            w == v.downcase
          end
        end.new

        f.should be_value_matches_value('x', 'X')
      end

      it 'can define weight' do
        f = described_class.insert do
          weight 5
        end.new

        f.weight.should == 5
      end
    end

  end

  context '.[]' do
    it 'returns results for the given source' do
      k = described_class.insert do
        def results # stub
          [23]
        end
      end

      k[double].should == [23]
    end
  end

  context '.load_all' do
    it 'loads some finders' do
      described_class.load_all
      described_class.all.should have_at_least(1).items
    end
  end

  context '#candidate?' do
    context 'for words' do
      subject { described_class.insert {
        words { |v| v.split('') }
        match_word { |w,v| v.include?(w) }
      }.new(source) }
      let(:source) { double(name: 'usB') }

      it 'approves candidate with matching word in #name' do
        subject.should be_candidate( double(name: 'USB') )
      end

      it 'disapproves candidate without matching word in #name' do
        subject.should_not be_candidate( double(name: 'USA') )
      end
    end

    context 'for value' do
      subject { described_class.insert {
        match_value { |e,v| e.downcase == v.downcase }
      }.new(source) }
      let(:source) { double(name: 'usB') }

      it 'approves candidate with matching value of #name' do
        subject.should be_candidate( double(name: 'USB') )
      end

      it 'disapproves candidate without matching value of #name' do
        subject.should_not be_candidate( double(name: 'USA') )
      end
    end
  end

end
