require 'pathname'
require 'monads/optional'

module Miwomi
  class Finder < Struct.new(:source)
    def self.all
      @all ||= []
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
      self.class.configuration.fetch(:word_builder) { ->(x) {x} }[source]
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
      conf(:source_attribute) { :name }
    end
    def candidate_attribute
      conf(:candidate_attribute) { :name }
    end

    class_attribute :word_matcher
    def self.match_word(&block)
      ensure_subklass!
      self.word_matcher = block
    end
    def word_matches_value?(word, value)
      optional(self.class.word_matcher).call(word, value).value
    end




  private

    def optional(value)
      Monads::Optional.new(value)
    end
  end
end

