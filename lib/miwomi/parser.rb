require 'miwomi/collection'

module Miwomi
  class Parser
    # Chooses the right parser based on the file extension
    def self.parse_file(file_path)
      klass =
        case file_path.to_s
        when /\.csv$/i
          CsvParser
        when /\.txt$/i
          DumpParser
        when /\.dump$/i
          DumpParser
        else
          raise ArgumentError, "cannot detect parser for #{file_path}"
        end
      parser = klass.new
      parser.parse_file(file_path)
    end



    def parse_file(file_path)
      parse File.read(file_path)
    end

    def new_result
      Collection.new.tap do |r|
        yield r
        r.compact!
      end
    end

  end
end
