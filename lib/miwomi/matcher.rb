module Miwomi
  class Matcher
    attr_reader :source
    def initialize(source, options={})
      @source = source
      @finders = options.fetch(:finders) { Finder.all_for(source) }
    end

    def candidates
      @candidates ||= []
    end

    def run
      @finders.each do |finder|
        finder_name = finder.internal_name
        result = finder.results
        unless result
          raise "finder did return nil, should return at least empty array: #{finder}"
        end
        @tried[finder_name] = result
        if result.length == 1
          return result.first
        # matching in some way AND the id is the same? looks like we found it
        elsif exact = result.find { |f| f.id == source.id }
          return exact
        else
          result
        end
      end.flatten.compact
    end

  end
end
