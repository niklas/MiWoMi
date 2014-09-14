module Miwomi
  class Translation < Struct.new(:from, :to)
    def to_midas
      %Q~# #{from.name} => #{to.name}\n#{from.id} -> #{to.id}~
    end
  end
end
