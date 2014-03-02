require 'miwomi/collection'

module Miwomi
  class Parser
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
