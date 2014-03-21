require 'miwomi/block'
require 'miwomi/item'

module Miwomi
  class Collection < Array

    class BadType < Exception; end

    def find_by_id(want)
      find { |x| x.id == want }
    end

    def add_thing(typ, *a)
      case typ.downcase
      when 'block'
        self << Block.new(*a)
      when 'item'
        self << Item.new(*a)
      else
        raise BadType, typ
      end
    end

    def of_type(other)
      select { |i| i.is_a?(other.class) }
    end

  end
end
