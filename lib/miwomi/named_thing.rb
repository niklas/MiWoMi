# a Thing appearing in the minecraft world that has a name
module Miwomi
  class NamedThing < Struct.new(:id, :name)
    attr_reader :klass
    def initialize(id, name, klass=nil)
      @klass = klass
      super(id, name)
    end
    def block?
      false
    end

    def item?
      false
    end

    def to_s
      k = descriptive_klass.to_s
      k = " [#{k}]" unless k.empty?
      %Q~<#{short_class_name} #{descriptive_name.inspect} (#{id})#{k}>~
    end

    def short_class_name
      self.class.name.split(':').last
    end

    def <=>(other)
      id <=> other.id
    end

    def descriptive_name
      @descriptive_name ||= name.dup.tap do |m|
        m.sub! /^([\w_]+):/i, ''
        remove_kill_words(m)
      end
    end

    def descriptive_klass
      @descriptive_klass ||= (klass.presence || '').tap do |m|
        m.sub! 'net.minecraft.block.', ''
        remove_kill_words(m)
      end
    end

    def name_without_namespace
      @name_without_namespace ||=
        if name =~ /^([\w_]+):(.+)$/i
          $2
        else
          name
        end
    end
  private
    KillWords = %w(
      tile
      block
      minecraft
    ).map(&:downcase)
    KillWordsExpr = /[_.]*(?:#{KillWords.join('|')})[_.]*/i
    def remove_kill_words(m)
      m.gsub!(KillWordsExpr, '')
    end
  end
end

