require 'miwomi/parser'

module Miwomi
  class DumpParser < Parser

    class Exception < ::Exception; end
    class BadLine < Exception; end
    class BadLineData < Exception; end

    NameAndId = /^Name:\s+(?<name>.+).\s+ID:\s+(?<id>\d+)$/i

    def parse(string)
      new_result do |result|
        string.lines.each do |line|
          case line
          when /^(?:\w+)\. Unused/i
            # ignore that
          when /^(Block|Item)\.\s+(.*)$/
            typ = $1
            if match = $2.match(NameAndId)
              result.add_thing typ, match[:id].to_i, match[:name]
            else
              raise(BadLineData, line)
            end
          else
            raise(BadLine, line)
          end
        end
      end
    end

  end
end
