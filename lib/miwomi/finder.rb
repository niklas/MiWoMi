require 'pathname'

module Miwomi
  class Finder
    def self.all
      @all ||= []
    end

    def self.insert(&block)
      file = Pathname.new caller.first.split(':').first
      name = file.basename.sub_ext('').to_s.classify
      Class.new(self, &block).tap do |klass|
        Miwomi::Finder.const_set name, klass
        all << klass
      end
    end
  end
end

