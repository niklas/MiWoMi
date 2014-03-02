# a Thing appearing in the minecraft world that has a name
module Miwomi
  class NamedThing < Struct.new(:id, :name)
    def block?
      false
    end

    def item?
      false
    end
  end
end

