require 'digest/sha1'

module Miwomi
  class Patch
    include Logger
    attr_reader :translations
    attr_reader :keeps
    attr_reader :from, :to
    attr_reader :options

    def initialize(from, to, options=self.class.default_opts)
      @from    = from
      @to      = to
      @options = options
      prepare
    end

    class Error < RuntimeError
    end

    class NoMatchFound < Error
    end

    class AmbigousMatch < Error
    end

    class IncompatibeType < Error
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
        options.move_ids  = {}
        options.alternatives = []
        options.verbose = false
        options.progressbar = false
        options.output_filename = nil
        options.progress_path = nil
        options.auto_progress_path = false
        options.interactive = false
      end
    end

    def apply
      prepare
      from.each do |source|
        progressbar.increment if options.progressbar
        next if has_already_processed?(source)
        if requested = options.move_ids[source.id]
          found_translation_by_id(source, requested)
          next
        end
        keep(source) && next if TechnicalBlocks.include?(source.id)
        keep(source) && next if options.keep_ids.include?(source.id)
        drop(source) && next if options.drop_ids.include?(source.id)
        drop(source) && next if options.drop.any? { |ign| source.name.include?(ign) }
        if to.find { |t| t.id == source.id && t.name == 'tile.ForgeFiller' }
          next # NEI.csv does not drop vanilla items by name
        end
        if match = find_match(source)
          unless match.is_a?(source.class)
            next if [:moved, :kept, :dropped].include?(match)
            raise IncompatibeType, "cannot translate #{source} into #{match}"
          end

          if source == match
            keep(source) && next
          end

          found_translation(source, match)
        else
          hint = argument_hint(source)
          raise NoMatchFound, "no match found for #{source}\n\n#{hints.join("\n")}"
        end
      end
    ensure
      save if options.interactive || options.progress_path || options.auto_progress_path
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
      options.output_filename || automatic_filename('midas')
    end

    def progress_path
      options.progress_path || (options.auto_progress_path && automatic_filename('yaml'))
    end

    def save(path=progress_path)
      if path
        File.open path, 'w' do |f|
          f.write to_yaml
        end
      end
    end

    def resume(path=progress_path)
      if path && File.exist?(path)
        parsed = YAML.load File.read(path)
        if p = parsed.fetch('translations')
          @translations = Translation.from_array_of_hashes p, from, to
        end
        @keeps = parsed.fetch('keeps').map { |kid| from.find_by_id(kid) }
      end
    end

    def encode_with encoder
      encoder.tag = nil
      encoder['translations'] = @translations
      encoder['keeps'] = @keeps.map(&:id)
    end

    def has_already_processed?(thing)
      keeps.include?(thing) ||
        translations.any? { |t| t.from == thing }
    end

  private
    def found_translation(source, match)
      translation = Translation.new(source, match)
      if options.verbose
        $stderr.puts translation.to_midas
      end
      @translations << translation
      translation
    end

    def found_translation_by_id(source, id)
      found_translation source, to.find_by_id(id)
    end

    def drop(source)
      found_translation source, source.class.new( 0, "dropped")
    end

    def keep(source)
      @keeps << source
    end

    def aquivalent(source)
      to.find_by_id(source)
    end

    def find_match(source)
      matcher = Matcher.new(source, list: to, options: options)
      benchmark "match #{source}" do
        matcher.run
      end
      candidates = matcher.candidates

      if candidates.length == 1
        return candidates.first.thing
      end

      if candidates.length > 1
        if best = matcher.best_candidate
          return best
        elsif options.interactive
          if solved = make_interactive_choice(matcher)
            return solved
          end

        else
          matcher.write_results_by_finder(hints)
          matcher.write_candidates_hint(hints)
        end
      end

      hints << argument_hint(source)
      raise AmbigousMatch, (
        [
          "could not find fuzzy match for",
         "   #{source}",
          "found #{candidates.length} candidates"
        ] +
        hints
      ).join("\n")
    end

    def prepare
      Finder.load_all
      @translations = []
      @keeps = []
      resume
    end

    def progressbar
      @progressbar ||= ProgressBar.create title: 'mining..', total: from.length, format: "%t %p%%: |%B|"
    end

    def automatic_filename(ext='data')
      hash = Digest::SHA1.hexdigest [from, to].map(&:inspect).reduce(&:+)
      "#{hash}.#{ext}"
    end

    def hints
      @hints ||= []
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

    def make_interactive_choice(matcher)
      if options.interactive
        source = matcher.source
        $stdout.puts
        matcher.puts_candidates(limit=5)

        require 'highline/import'
        prompt = "\nCould not find fuzzy match for #{source}"
        say(prompt)
        solved = false
        until solved do
          choose do |menu|
            menu.layout = :menu_only

            menu.shell  = true

            menu.choice(:keep, 'Keep it unchanged.') do |command, details|
              keep(source)
              aqui = aquivalent(source)
              say "Keep it, will be #{aqui}\n"
              solved = :kept
            end

            menu.choice(:move, 'Provide a new block id to move to.') do |command, details|
              num = details.to_i
              if num > 0
                trans = found_translation_by_id(source, details)
                say "Moved to #{trans.to}\n"
                solved = :moved
              else
                say "not a block id: #{details}\n"
              end
            end

            menu.choice(:drop, 'Drop/Delete it.') do |command, details|
              drop(source)
              say "Deleted."
              solved = :dropped
            end

            menu.choice(:all, 'Show all candidates') do |command, details|
              limit = 2 * limit
              matcher.puts_candidates(limit)
              say(prompt)
            end

            menu.choice(:quit, "Exit program.") { return false }
          end
        end
        return solved
      end
    end
  end
end
