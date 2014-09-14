Miwomi::Finder.insert do
  attribute :descriptive_name

  match_value do |source, candidate|
    source == candidate
  end
end

