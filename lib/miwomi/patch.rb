module Miwomi
  class Patch < Struct.new(:from, :to)
    attr_reader :translations

    class Translation < Struct.new(:from, :to)
    end

    def apply
      @translations = []
      from.each do |f|
        match = to.find { |t| t.name == f.name }
        if match
          @translations << Translation.new(f, match)
        else
          raise "no match found for #{f}"
        end
      end
    end
  end
end
