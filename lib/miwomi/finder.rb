require 'pathname'
require 'monads/optional'

module Miwomi
  class Finder
    def self.all
      @all ||= []
    end

    def self.undefine_all
      self.constants.each do |const|
        remove_const const
      end
    end

    def self.insert(options={}, &block)
      name = options.fetch(:name) do
        Pathname.new(caller[2].split(':').first).basename.sub_ext('')
      end
      klass_name = name.to_s.classify
      Class.new(self, &block).tap do |klass|
        const_set klass_name, klass
        all << klass
      end
    end

    def self.ensure_subklass!
      raise "please use Miwomi::Finder.insert" if self == Miwomi::Finder
    end


    ######################################################################################
    # DSL
    ######################################################################################

    class_attribute :word_builder
    def self.words(&block)
      ensure_subklass!
      self.word_builder = block
    end
    def words
      optional(self.class.word_builder).call(source).value
    end

    class_attribute :candidate_attribute
    def self.attribute(attr_name)
      ensure_subklass!
      self.candidate_attribute = attr_name
    end
    def attribute
      optional(self.class.candidate_attribute)
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

