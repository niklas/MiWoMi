require 'miwomi/block'
require 'miwomi/item'

module Miwomi
  class Collection < Array

    class BadType < Exception; end

    def find_by_id(want)
      want = want.id if want.respond_to?(:id)
      want = want.to_i if want.respond_to?(:to_i)
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
