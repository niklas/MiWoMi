module Miwomi
  class Matcher
    attr_reader :source
    def initialize(source, options={})
      @source = source
      @finders = options.fetch(:finders) { Finder.all_for(source) }
      @runNing = false
    end

    def candidates
      candidates_by_finder.values
    end

    class Candidate < Struct.new(:thing, :weight)
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

    def weighted_candidates(rehash=false)
      counter = Hash.new { |h,k| h[k] = 0 }
      @counted ||=
        candidates_by_finder.
          to_a.
          inject(counter) do |c,(finder,candidates)|
            candidates.each do |cand|
            c[cand.thing] += cand.weight
            end
            c
          end.
          sort_by { |k,v| -v }
      rehash ? Hash[@counted] : @counted
    end

    def best_candidate
      # if the first one was found more often then the second, use it
      winner = found_count[0]
      if winner[1] > 1 && winner[1] > found_count[1][1]
        return winner[0]
      end
    end

    def write_candidates_hint(io)
      found_count = weighted_candidates

      io << %Q~best candidates:~
      weighted_candidates(false).first(5).each do |thing, count|
        io << %Q~  #{count}: #{thing}~
      end
    end

  private

    def found!(finder, result, weight)
      candidates_by_finder[finder] << Candidate.new(result, weight)
    end

  end
end
