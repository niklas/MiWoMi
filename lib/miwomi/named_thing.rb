# a Thing appearing in the minecraft world that has a name
module Miwomi
  class NamedThing < Struct.new(:id, :name)
    def block?
      false
    end

    def item?
      false
    end

    def to_s
      %Q~<#{short_class_name} #{name.inspect} (#{id})>~
    end

    def short_class_name
      self.class.name.split(':').last
    end
  end
end

