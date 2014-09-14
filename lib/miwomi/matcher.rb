module Miwomi
  class Matcher
    include Miwomi::Logger

    attr_reader :source
    def initialize(source, options={})
      @source = source
      @finders = options.fetch(:finders) { Finder.all_for(source, list: options[:list], options: options[:options]) }
      @runNing = false
    end

    def candidates
      candidate_by_result.values.flatten
    end

    class Candidate < Struct.new(:thing, :weight)
      def finders
        @finders ||= Set.new
      end
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
        results = benchmark "running Finder: #{finder_name}" do
          finder.results
        end
        unless results
          raise "finder did return nil, should return at least empty array: #{finder}"
        end

        # TODO recalculate results for alternatives here

        results.each do |result|
          found! finder, result, 1

          # only one? that's special
          if results.count == 1
            found! finder, result, 2
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
            c[candidate] = candidate.weight
            c
          end.
          sort_by { |k,v| -v }
      rehash ? Hash[@counted] : @counted
    end

    def best_candidate
      weights = weighted_candidates(false)
      # if the first one weights much more than the second, use it
      t = weights[0]
      top_weight = t[1]
      top = t[0].thing

      n = weights[1]
      nxt_weight = n[1]
      nxt = n[0].thing


      if top_weight > 10 # must have at least so many points
        if (0..6).cover?(nxt_weight)      || # next one is so small, we must be the winner
            top_weight > nxt_weight + 10  || # winner is 10 points ahead
            top_weight > nxt_weight * 1.5 || # winner has 50% more points
            top == source                 || # Identity is kept per points
            false                            ## better diffs
          return top
        elsif nxt == source               || # close miss
            (nxt_weight = 0 && top_weight > nxt_weight) || # no other candidates
            false
          return nxt
        end
      end
    end

    def write_candidates_hint(io)
      io << %Q~best candidates:~
      weighted_candidates(false).first(5).each do |candidate, weight|
        io << "% 5i: %s" % [weight,candidate.thing]
        finders = candidate.finders.
          sort_by(&:weight).
          reverse.
          map(&:internal_name_with_weight).
          join(', ')
        io << "       #{finders}"
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
      w = weight * finder.weight
      if candidate = candidate_by_result[result]
        candidate.weight += w
      else
        candidate = candidate_by_result[result] = Candidate.new(result, w)
      end
      candidate.finders << finder
      candidates_by_finder[finder] << candidate
    end

  end
end
