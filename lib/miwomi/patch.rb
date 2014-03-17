module Miwomi
  class Patch < Struct.new(:from, :to)
    attr_reader :translations

    class Translation < Struct.new(:from, :to)
    end

    def apply
      @translations = []
      from.each do |source|
        if match = find_match(source)
          unless match.is_a?(source.class)
            raise ArgumentError, "cannot translate #{source} into #{match}"
          end

          @translations << Translation.new(source, match)
        else
          raise "no match found for #{source}"
        end
      end
    end

  private
    def find_match(source)
      to.find { |t| t.name == source.name }
    end
  end
end
