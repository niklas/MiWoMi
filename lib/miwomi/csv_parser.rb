require 'miwomi/parser'
require 'csv'

module Miwomi
  class CsvParser < Parser
    class BadThing < Exception; end

    def parse(string)
      new_result do |result|
        CSV.parse(
          string,
          headers:true,
          header_converters: :symbol,
          skip_lines: /^\d+[^,]*,null/,
          converters: :all
        ).each do |row|
          case row[:blockitem]
          when 'null'
            # ignore that
          when /^Block|Item$/
           result.add_thing row[:blockitem], row[:id].to_i, row[:unlocalised_name], row[:class]
          else
            raise BadThing, row
          end
        end
      end
    end
  end
end
