module Miwomi
  class DumpParser
    class BadLine < Exception; end

    def parse(string)
      new_result.tap do |result|
        string.lines.each do |line|
          case line
          when /^Block\.\s+(.*)$/
            result << $1
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

    def new_result
      []
    end
  end
end
