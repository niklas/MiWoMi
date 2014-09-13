module Miwomi
  class Finder
    def self.all
      @all ||= []
    end

    def self.insert(&block)
      Class.new(self).tap do |klass|
        all << klass
      end
    end
  end
end

