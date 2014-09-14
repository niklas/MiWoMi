module Miwomi
  class Matcher
    attr_reader :source
    def initialize(source, options={})
      @source = source
      @finders = options.fetch(:finders) { Finder.all_for(source) }
    end

    def candidates
      candidates_by_finder.values
    end

    def candidates_by_finder
      @candidates ||= Hash.new {|h,v| h[v] = [] }
    end

    def run
      @finders.each do |finder|
        finder_name = finder.internal_name
        results = finder.results
        unless results
          raise "finder did return nil, should return at least empty array: #{finder}"
        end

        results.each do |result|
          found! finder, result, 1

          # only one? that's special
          if results.count == 1
            found! finder, result, 5
          end

          # matching in some way AND the id is the same? looks like we found it
          if result.id == source.id
            found! finder, result, 12
          end

        end
      end
    end

  private

    def found!(finder, result, weight)
      candidates_by_finder[finder] << result
    end

  end
end
