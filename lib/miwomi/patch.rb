module Miwomi
  class Patch < Struct.new(:from, :to)
    attr_reader :translations

    class Error < RuntimeError
    end

    class NoMatchFound < Error
      def message
        "no match found for #{super}"
      end
    end

    class AmbigousMatch < Error
    end

    class IncompatibeType < Error
    end

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
        options.ignore_ids  = []
        options.verbose = false
      end
    end

    def apply(opts=self.class.default_opts)
      @translations = []
      from.each do |source|
        next if TechnicalBlocks.include?(source.id)
        next if opts.ignore.any? { |ign| source.name.include?(ign) }
        next if opts.ignore_ids.include?(source.id)
        if match = find_match(source)
          unless match.is_a?(source.class)
            raise IncompatibeType, "cannot translate #{source} into #{match}"
          end

          @translations << Translation.new(source, match)
        else
          if to.find { |t| t.id == source.id && t.name = 'tile.ForgeFiller' }
            next # NEI.csv does not drop vanilla items by name
          end
          raise NoMatchFound, source
        end
      end
    end

  private
    def find_match(source)
      find_match_by_exact_name(source.name) ||
        find_match_by_substrings(source.name)
    end

    def find_match_by_exact_name(name)
      to.find { |t| t.name == name }
    end

    def find_match_by_substrings(name)
      name.scan(/\w+/i).reverse.each do |substr|
        found = to.select { |t| t.name.downcase.include?(substr.downcase) }

        if found.length > 1
          if found.length <13 
            raise AmbigousMatch, "could not find fuzzy match for #{name.inspect} " +
              "found #{found.length} possibilities: #{found.join("\n")}"
          else
            return nil # to many fuzzy matches, user should try something else
          end
        end

        if found.length == 1
          return found.first
        end
      end

      nil # failed to find any candidate
    end
  end
end
