Miwomi::Finder.insert do
  attribute :descriptive_name
  weight 3

  match_value do |source, candidate|
    source == candidate
  end
end

