require 'digest/sha1'

module Miwomi
  class Patch
    attr_reader :translations
    attr_reader :from, :to
    attr_reader :options

    def initialize(from, to, options=self.class.default_opts)
      @from    = from
      @to      = to
      @options = options
    end

    class Error < RuntimeError
    end

    class NoMatchFound < Error
    end

    class AmbigousMatch < Error
    end

    class IncompatibeType < Error
    end

    class Translation < Struct.new(:from, :to)
      def to_midas
        %Q~# #{from.name} => #{to.name}\n#{from.id} -> #{to.id}~
      end
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
        options.drop  = []
        options.drop_ids  = []
        options.alternatives = []
        options.verbose = false
        options.progressbar = false
        options.output_filename = nil
      end
    end

    def apply
      @translations = []
      from.each do |source|
        progressbar.increment if options.progressbar
        next if TechnicalBlocks.include?(source.id)
        drop(source) && next if options.drop_ids.include?(source.id)
        drop(source) && next if options.drop.any? { |ign| source.name.include?(ign) }
        if to.find { |t| t.id == source.id && t.name == 'tile.ForgeFiller' }
          next # NEI.csv does not drop vanilla items by name
        end
        if match = find_match(source)
          unless match.is_a?(source.class)
            raise IncompatibeType, "cannot translate #{source} into #{match}"
          end

          if source == match
            next
          end

          found_translation(source, match)
        else
          raise NoMatchFound, "no match found for #{source}, tried:\n#{tries}"
        end
      end
    ensure
      progressbar.stop if options.progressbar
    end

    def apply_and_write
      apply
      file = output_filename
      File.open file, 'w' do |f|
        f.print to_midas
      end
      $stderr.puts "written to #{file}"
    end

    def to_s
      %Q~<#{self.class} from #{from.length} to #{to.length} things>~
    end

    def to_midas
      translations.map(&:to_midas).join("\n")
    end

    def output_filename
      options[:output_filename] || output_filename_from_collections
    end

  private
    def found_translation(source, match)
      translation = Translation.new(source, match)
      if options.verbose
        $stderr.puts translation.to_midas
      end
      @translations << translation
    end

    def drop(source)
      found_translation source, source.class.new( 0, "dropped")
    end

    def finders
      @finders = [].tap do |finders|
        #finders << lambda {|s| find_match_by_same_id s }
        finders << [:exact_name,         lambda {|s| find_match_by_exact_name s } ]
        finders << [:alternative_names,  lambda {|s| find_match_by_alternative_name s } ]
        finders << [:case_ins_name,      lambda {|s| find_match_by_case_insensitive_name s } ]
        finders << [:word_of_klass,      lambda {|s| find_match_by_word(s, :klass) } ]
        finders << [:word_of_name,       lambda {|s| find_match_by_word(s, :name) } ]
        finders << [:substring_of_klass, lambda {|s| find_match_by_substring(s, :klass) } ]
        finders << [:substring_of_name,  lambda {|s| find_match_by_substring(s, :name) } ]
      end
    end

    def tries
      if @tried.empty?
        'nothing'
      else
        indent = lambda { |f| "    #{f}" }
        @tried.map do |name, found|
          [ "  #{name}:" ] +
          if found.length > 7
            found[0..6].map(&indent) +
              [ indent["... and #{found.length - 7} more"] ]
          else
            found.map(&indent)
          end
        end.flatten.join("\n")
      end
    end

    def find_match(source)
      @tried = {}
      found = finders.map do |finder_name,finder|
        result = finder[source]
        unless result
          raise "finder did return nil, should return at least empty array: #{finder}"
        end
        @tried[finder_name] = result
        if result.length == 1
          return result.first
        # matching in some way AND the id is the same? looks like we found it
        elsif exact = result.find { |f| f.id == source.id }
          return exact
        else
          result
        end
      end.flatten.compact.sort.uniq


      if 1 < found.length && found.length < 13
        raise AmbigousMatch, "could not find fuzzy match for #{source} " +
          "\ntried:\n#{tries}" +
          "\nfound #{found.length} possibilities:\n#{found.join("\n")}"
      end
      nil
    end

    def find_match_by_same_id(source)
      []
    end

    def find_match_by_exact_name(source)
      to.of_type(source).select { |t| t.name == source.name }
    end

    def find_match_by_alternative_name(source)
      options.alternatives.map do |original, alt|
        if source.name.include?(original)
          to.of_type(source).select { |t| t.name == source.name.gsub(Regexp.new(original), alt) }
        else
          nil
        end
      end.flatten.compact.uniq
    end

    def find_match_by_case_insensitive_name(source)
      name = source.name.downcase
      to.of_type(source).select { |t| t.name.downcase == name }
    end

    def find_match_by_word(source, attr=:name)
      name = source.name
      name.scan(/\w+/i).reverse.map do |substr|
        next if substr == 'tile'
        next if substr == 'minecraft'
        exp = /\b#{substr}\b/i
        found = to.of_type(source).select do |t|
          if val = t.public_send(attr)
            val =~ exp
          end
        end
        if found.length == 1
          return found
        end
        found.length < 8 ? found : []
      end.flatten.compact.uniq
    end

    def find_match_by_substring(source, attr=:name)
      name = source.name
      name.scan(/\w+/i).reverse.map do |substr|
        next if substr == 'tile'
        next if substr == 'minecraft'
        found = to.of_type(source).select do |t|
          if val = t.public_send(attr)
            val.downcase.include?(substr.downcase)
          end
        end
        unless found.empty?
          return found
        end
        found.length < 8 ? found : []
      end.flatten.compact.uniq
    end

    def progressbar
      @progressbar ||= ProgressBar.create title: 'mining..', total: from.length, format: "%t %p%%: |%B|"
    end

    def output_filename_from_collections
      hash = Digest::SHA1.hexdigest from.inspect + to.inspect + options.inspect
      "#{hash}.midas"
    end
  end
end
