require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)


module MineCraft
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
        @region.exportToFile @region_path
      end
    end

    private

    def region
      @region ||= Region.fromFile(@region_path)
    end

    def generate_entrance
      c = region.cube(Base, 0, 0, :width => 10, :length => 10, :height => 12)
      c.each do |block, z, x, y|
         block.name = :wool
         block.color = :orange
      end
    end
  end
end

if __FILE__ == $0
  unless ARGV.length == 2
    STDERR.puts <<-EOHELP
  invocation: #{$0} region_path path
    region_path: ~/.minecraft/saves/???mcr
    path:        ~/path/to_dir/
    EOHELP
    exit -2
  end

  begin
    MineCraft::FileLandscape.generate *ARGV
  rescue Exception => e
    STDERR.puts e.message
    exit -10
  end
end
