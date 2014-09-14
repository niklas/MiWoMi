module Miwomi
  class Matcher
    attr_reader :source
    def initialize(source, options={})
      @source = source
      @finders = options.fetch(:finders) { Finder.all_for(source, list: options[:list]) }
      @runNing = false
    end

    def candidates
      candidate_by_result.values.flatten
    end

    class Candidate < Struct.new(:thing, :weight)
    end

    def candidates_by_finder
      @candidates_by_finder ||= Hash.new {|h,v| h[v] = [] }
    end

    def candidate_by_result
      @candidate_by_result ||= Hash.new
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
        candidate_by_result.
          to_a.
          inject(counter) do |c,(result,candidate)|
            c[result] = candidate.weight
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
      weighted_candidates(false).first(5).each do |thing, weight|
        io << '% 5i: %s' % [weight,thing]
      end
    end

    def write_results_by_finder(io)
      indent = lambda { |f| "    #{f}" }
      io << 'tried:'
      candidates_by_finder.map do |finder, candidates|
        name = finder.internal_name
        found = candidates.map(&:thing)
        [ "  #{name}:" ] +
        if found.length > 7
          found[0..6].map(&indent) +
            [ indent["... and #{found.length - 7} more"] ]
        else
          found.map(&indent)
        end
      end.each { |l| io << l }
    end

  private

    def found!(finder, result, weight)
      if candidate = candidate_by_result[result]
        candidate.weight += weight
      else
        candidate = candidate_by_result[result] = Candidate.new(result, weight)
      end
      candidates_by_finder[finder] << candidate
    end

  end
end
