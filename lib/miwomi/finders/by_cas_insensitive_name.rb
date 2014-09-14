Miwomi::Finder.insert do
  attribute :descriptive_name
  weight 2

  match_value do |source, candidate|
    source.downcase == candidate.downcase
  end
end

