require 'fileutils'

module Miwomi
  class FileLandscape
    include RubyCraft

    Base = 4

    class WorldNotFound < Errno::ENOENT
      def message
        "World not found, please generate with minecraft first: #{super}"
      end
    end

    def self.generate(region_path, path)
      new(region_path, path).generate
    end

    def initialize(region_path, path)
      @path = path
      @region_path = region_path

      unless File.exist?(region_path)
        raise WorldNotFound, region_path
      end
    end

    def generate
      generate_entrance
      save
    end

    def save
      if @region
        copy = "#{@region_path}.recent"
        debug { "saving to #{copy}" }
        @region.exportToFile copy
        debug { "saved." }
        FileUtils.mv copy, @region_path
        debug { "overwritten original #{@region_path}." }
      end
    end

    private

    def region
      return @region if @region
      debug { "loading from #{@region_path}" }
      @region = Region.fromFile(@region_path)
    end

    def generate_entrance
      c = region.cube(Base, 0, 0, :width => 10, :length => 10, :height => 12)
      c.each do |block, z, x, y|
         block.name = :wool
         block.color = :orange
      end
    end

    def debug(msg='')
      STDERR.puts msg unless msg.empty?
      if block_given?
        STDERR.puts yield
      end
    end
  end
end
