Miwomi::Finder.insert do
  attribute :descriptive_name
  weight 8

  match_value do |mine, theirs|
    theirs.include?(mine.underscore)
  end
end

