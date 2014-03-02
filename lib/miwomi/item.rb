require 'miwomi/named_thing'

module Miwomi
  class Item < NamedThing
    def item?
      true
    end
  end
end

