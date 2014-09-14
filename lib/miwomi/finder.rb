require 'pathname'
require 'monads/optional'

module Miwomi
  class Finder
    include Logger

    def self.all
      @all ||= []
    end

    def self.all_for(source, options={})
      all.map { |f| f.new(source, options) }
    end

    def self.undefine_all
      all.each do |f|
        remove_const f.name.demodulize
      end
      @all = nil
    end

    def self.load_all
      Dir[ "#{Pathname.new(__FILE__).sub_ext('')}s/*.rb" ].each do |f|
        require f
      end
    end

    def self.insert(options={}, &block)
      name = options.fetch(:name) do
        Pathname.new(caller[2].split(':').first).basename.sub_ext('')
      end
      klass_name = name.to_s.classify
      Class.new(self, &block).tap do |klass|
        const_set klass_name, klass

        if (iname = options[:after]) && (pos = all.index { |k| k.internal_name == iname })
          all.insert pos+1, klass
        elsif (iname = options[:before]) && (pos = all.index { |k| k.internal_name == iname })
          all.insert pos, klass
        else
          all << klass
        end
      end
    end

    def self.internal_name
      name.demodulize.underscore
    end

    def self.ensure_subklass!
      raise "please use Miwomi::Finder.insert" if self == Miwomi::Finder
    end

    def self.[](source)
      new(source).results
    end

    ######################################################################################
    # Instance Methods
    ######################################################################################

    attr_reader :source
    attr_reader :options
    def initialize(source=[], options={})
      @source = source
      @list = options.fetch(:list) { [] }
      @options = options[:options]
    end

    def results
      @list.of_type(source).select &method(:candidate?)
    end

    def candidate?(cand)
      value = cand.public_send(candidate_attribute)
      if has_words?
        words.any? do |word|
          word_matches_value?(word, value)
        end
      else
        value_matches_value? source.public_send(source_attribute), value
      end
    end

    def internal_name
      self.class.internal_name
    end

    ######################################################################################
    # DSL
    ######################################################################################

    class_attribute :configuration
    def self.inherited(child)
      super
      child.configuration = {}
    end
    def conf(key, &default)
      configuration.fetch(key, &default)
    end

    def self.words(&block)
      ensure_subklass!
      configuration[:word_builder] = block
    end
    def words
      @words ||= begin
        builder = configuration.fetch(:word_builder) { ->(x) {x} }
        builder[source.public_send(source_attribute)]
      end
    end
    def has_words?
      configuration.has_key?(:word_builder)
    end

    def self.attribute(attr_name)
      ensure_subklass!
      source_attribute attr_name
      candidate_attribute attr_name
    end
    def self.source_attribute(attr_name)
      configuration[:source_attribute] = attr_name
    end
    def self.candidate_attribute(attr_name)
      configuration[:candidate_attribute] = attr_name
    end
    def source_attribute
      @source_attribute ||= conf(:source_attribute) { :name }
    end
    def candidate_attribute
      @candidate_attribute ||= conf(:candidate_attribute) { :name }
    end

    class_attribute :word_matcher
    def self.match_word(&block)
      ensure_subklass!
      self.word_matcher = block
    end
    def word_matches_value?(word, value)
      instance_exec word, value, &self.class.word_matcher
    end

    class_attribute :value_matcher
    def self.match_value(&block)
      ensure_subklass!
      self.value_matcher = block
    end
    def value_matches_value?(mine, theirs)
      instance_exec mine, theirs, &self.class.value_matcher
    end




  private

    def optional(value)
      Monads::Optional.new(value)
    end
  end
end

