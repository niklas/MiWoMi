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

    def self.insert(&block)
      file = Pathname.new caller.first.split(':').first
      name = file.basename.sub_ext('').to_s.classify
      Class.new(self, &block).tap do |klass|
        const_set name, klass
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




  private

    def optional(value)
      Monads::Optional.new(value)
    end
  end
end

