Miwomi::Finder.insert do
  attribute :id
  weight 15

  match_value do |source, candidate|
    source == candidate
  end
end

