module Miwomi
  class Patch < Struct.new(:from, :to)
    attr_reader :translations

    class Translation < Struct.new(:from, :to)
    end

    # some blocks are internal, see http://minecraft.gamepedia.com/Technical_blocks
    TechnicalBlocks = [
      26,   # Bed
      34,   # Piston Head
      36,   # Moving Piston
      55,   # Redstone on ground
      59,   # Crops
      63,   # Sign
      64,   # Door
      68,   # Sign
      71,   # Door
      74,   # Lit Redstone Ore
      75,   # Unlit Redstone Torch
      83,   # Reed
      92,   # Cake
      93,   # Redstone Repeater
      94,   # Redstone Repeater
      104,  # Pumpkin Stem
      105,  # Melon Stem
      115,  # Nether Wart
      117,  # Brewing Stand
      118,  # Cauldron
      119,  # BlockEndPortal
      124,  # Lit Redstone lamp
      132,  # Trip Wire
      140,  # Flower Pot
      144,  # Skull
      149,  # Redstone Comparator
      150,  # Redstone Comparator
    ]

    def self.default_opts
      OpenStruct.new.tap do |options|
        options.ignore  = []
        options.verbose = false
      end
    end

    def apply(opts=self.class.default_opts)
      @translations = []
      from.each do |source|
        next if TechnicalBlocks.include?(source.id)
        next if opts.ignore.any? { |ign| source.name.include?(ign) }
        if match = find_match(source)
          unless match.is_a?(source.class)
            raise ArgumentError, "cannot translate #{source} into #{match}"
          end

          @translations << Translation.new(source, match)
        else
          raise "no match found for #{source}"
        end
      end
    end

  private
    def find_match(source)
      to.find { |t| t.name == source.name }
    end
  end
end
