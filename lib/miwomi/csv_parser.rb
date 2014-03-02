require 'miwomi/parser'
require 'miwomi/block'
require 'miwomi/item'
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
          when 'Block'
           result << Block.new( row[:id].to_i, row[:unlocalised_name] )
          when 'Item'
           result << Item.new( row[:id].to_i, row[:unlocalised_name] )
          else
            raise BadThing, row
          end
        end
      end
    end
  end
end
