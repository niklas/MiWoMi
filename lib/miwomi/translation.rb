module Miwomi
  class Translation < Struct.new(:from, :to)
    def to_midas
      %Q~# #{from.name} => #{to.name}\n#{from.id} -> #{to.id}~
    end

    def filled?
      from && to
    end

    def to_yaml
      {
        'from' => from.id,
        'to'   => to.id
      }.to_yaml
    end

    class DeserializationFailed < ArgumentError; end

    def self.from_yaml(yaml, froms, tos)
      [].tap do |list|
        YAML.load(yaml).each do |i|
          from = froms.find_by_id(i['from'])
          to = tos.find_by_id(i['to'])

          tr = new from, to
          if tr.filled?
            list << tr
          else
            raise DeserializationFailed, "cannot deserialize #{i.inspect}, reached #{tr}"
          end
        end
      end
    end

    def self.new_from_hash(attrs={})
      new attrs['from'], attrs['to']
    end
  end
end
