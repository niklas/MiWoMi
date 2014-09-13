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
          when nil # no "Block/Item" row
            if row[:name] # 'minecraft:air'
              result.add_thing 'Block', row[:id].to_i, row[:name], row[:class]
              if row[:has_item] == 'true'
                result.add_thing 'Item', row[:id].to_i, row[:name], row[:class]
              end
            end
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
