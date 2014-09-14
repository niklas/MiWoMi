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
        options.keep_ids  = []
        options.alternatives = []
        options.verbose = false
        options.progressbar = false
        options.output_filename = nil
      end
    end

    def apply
      Finder.load_all
      @translations = []
      from.each do |source|
        progressbar.increment if options.progressbar
        next if TechnicalBlocks.include?(source.id)
        next if options.keep_ids.include?(source.id)
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
          hint = argument_hint(source)
          raise NoMatchFound, "no match found for #{source}, tried:\n#{tries}\n\n#{hints.join("\n")}"
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
        finders << [:exact_name,         ->(s) {
          find_match_by_exact s.name, s, :name } ]
        finders << [:name_without_namespace, ->(s) {
          find_match_by_exact s.name, s, :name_without_namespace } ]
        finders << [:exact_klass,        lambda {|s| find_match_by_exact_klass s } ]
        finders << [:alternative_names,  lambda {|s| find_match_by_alternative_name s } ]
        finders << [:case_ins_name,      lambda {|s| find_match_by_case_insensitive_name s } ]
        finders << [:word_of_klass,      lambda {|s| find_match_by_word(s.name, s, :klass) } ]
        finders << [:word_of_name,       lambda {|s| find_match_by_word(s.name, s, :name) } ]
        finders << [:substring_of_klass, lambda {|s| find_match_by_substring(s.name, s, :klass) } ]
        finders << [:substring_of_name,  lambda {|s| find_match_by_substring(s.name, s, :name) } ]
        finders << [:ore_substring_ignored,  lambda {|s|
          find_match_by_substring(s.name.gsub(/ore/i, ''), s, :name) } ]

        finders << [:camel_bumps_of_klass, lambda {|s| find_match_by_camel_bumps(s.klass, s, :klass) } ]
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
      matcher = Matcher.new(source)
      matcher.run
      candidates = matcher.candidates
      if candiates.length > 1
        matcher.write_candidates_hint(hint)
      end

      found = found.sort.uniq
      if 1 < found.length && found.length < 13
        hints << argument_hint(source)
        raise AmbigousMatch, "could not find fuzzy match for #{source} " +
          "\ntried:\n#{tries}" +
          "\nfound #{found.length} possibilities:\n#{found.join("\n")}\n\n#{hints.join("\n")}"
      end
      nil
    end

    def find_match_by_same_id(source)
      []
    end

    def find_match_by_exact(exp, source, attr=:name)
      to.of_type(source).select { |t| t.public_send(attr) == exp }
    end

    def find_match_by_exact_klass(source)
      to.of_type(source).select { |t| t.klass == source.klass }
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

    def find_match_by_word(name, source, attr=:name)
      select_including_any_word name.scan(/\w+/i).reverse, source, attr
    end

    def select_including_any_word(words, source, attr=:name)
      select_match_any words, source, attr, ->(w) { /\b#{w}\b/i } { |exp, v| !!exp.match(v) }
    end

    def find_match_by_substring(name, source, attr=:name)
      select_match_any_substring name.scan(/\w+/i).reverse, source, attr
    end

    def find_match_by_camel_bumps(exp, source, attr=:name)
      exp = exp.sub 'net.minecraft.block.', ''
      select_match_any_substring exp.underscore.scan(/[[:alnum:]]+/i).reverse, source, attr
    end

    def select_match_any_substring(substrings, source, attr)
      select_match_any substrings, source, attr, ->(s) { s.downcase } { |s,v| v.downcase.include?(s) }
    end

    def select_match_any(items, source, attr=:name, prepare=->(w) {w})
      items.map do |item|
        next if is_kill_word?(item)
        prepared = prepare[item]
        found = to.of_type(source).select do |t|
          if val = t.public_send(attr)
            yield(prepared, val)
          end
        end
        if found.length == 1
          return found
        end
        found.length < 23 ? found : []
      end.flatten.compact.uniq
    end

    def progressbar
      @progressbar ||= ProgressBar.create title: 'mining..', total: from.length, format: "%t %p%%: |%B|"
    end

    def output_filename_from_collections
      hash = Digest::SHA1.hexdigest from.inspect + to.inspect + options.inspect
      "#{hash}.midas"
    end

    def hints
      @hints ||= []
    end

    KillWords = %w(
      tile
      block
      minecraft
    ).map(&:downcase)
    def is_kill_word?(word)
      KillWords.include? word.downcase
    end


    def argument_hint(source)
      if identical = to.find_by_id(source)
        hint = <<-EOTXT
If you think it matches, add -k #{source.id} to keep
  #{source}
as
  #{identical}
EOTXT
      else
        hint = <<-EOTXT
If you don't care about the block
  #{source}
add -d #{source.id} to drop it.
EOTXT
      end
    end
  end
end
