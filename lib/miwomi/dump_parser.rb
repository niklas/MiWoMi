require 'miwomi/block'
require 'miwomi/item'

module Miwomi
  class DumpParser

    class Exception < ::Exception; end
    class BadLine < Exception; end
    class BadFoundLine < Exception; end

    def parse(string)
      new_result do |result|
        string.lines.each do |line|
          case line
          when /^(?:\w+)\. Unused/i
            # ignore that
          when /^Block\.\s+(.*)$/
            result << found_block($1)
          when /^Item\.\s+(.*)$/
            result << found_item($1)
          else
            raise(BadLine, line)
          end
        end
      end
    end

    def parse_file(file_path)
      parse File.read(file_path)
    end

    private

    NameAndId = /^Name:\s+(?<name>.+).\s+ID:\s+(?<id>\d+)$/i

    def found_block(line)
      if match = line.match(NameAndId)
        Block.new match[:id].to_i, match[:name]
      else
        raise BadFoundLine, line
      end
    end

    def found_item(line)
      if match = line.match(NameAndId)
        Item.new match[:id].to_i, match[:name]
      else
        raise BadFoundLine, line
      end
    end

    def new_result
      [].tap do |r|
        yield r
      end.compact
    end
  end
end
