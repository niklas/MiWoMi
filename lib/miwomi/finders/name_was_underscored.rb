Miwomi::Finder.insert do
  attribute :descriptive_name
  weight 9

  match_value do |source, candidate|
    source.underscore == candidate
  end
end

