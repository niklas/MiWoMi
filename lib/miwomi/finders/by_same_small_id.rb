Miwomi::Finder.insert do
  attribute :id
  weight 8 # very probably a vanilly item, keep unchanged

  match_value do |my_id, id|
    my_id < 100 && my_id == id
  end
end

