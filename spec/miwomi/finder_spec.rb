require 'spec_helper'

describe Miwomi::Finder do
  before do
    described_class.undefine_all
  end

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

        f.stub source: 'foo bar'
        f.words.should == ['foo', 'bar']
      end

      it 'can define attribute to call on every candidate' do
        f = described_class.insert do
          attribute :kloss
        end.new

        f.attribute.value.should == :kloss
      end

      it 'can define how words are matched' do
        f = described_class.insert do
          match_word do |w,v|
            w == v.downcase
          end
        end.new

        f.should be_word_matches_value('x', 'X')
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

end
