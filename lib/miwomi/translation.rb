module Miwomi
  class Translation < Struct.new(:from, :to)
    def to_midas
      %Q~# #{from.name} => #{to.name}\n#{from.id} -> #{to.id}~
    end

    def to_yaml
      {
        'from' => from.id,
        'to'   => to.id
      }.to_yaml
    end
  end
end
