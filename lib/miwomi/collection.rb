require 'miwomi/block'
require 'miwomi/item'

module Miwomi
  class Collection < Array

    class BadType < Exception; end

    def find_by_id(want)
      find { |x| x.id == want }
    end

    def add_thing(typ, id, name)
      case typ.downcase
      when 'block'
        self << Block.new(id, name)
      when 'item'
        self << Item.new(id, name)
      else
        raise BadType, typ
      end
    end

  end
end
