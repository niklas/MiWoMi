Miwomi::Finder.insert do
  attribute :id

  match_value do |source, candidate|
    source == candidate
  end
end

