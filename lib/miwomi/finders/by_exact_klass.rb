Miwomi::Finder.insert do
  attribute :descriptive_klass

  match_value do |source, candidate|
    source == candidate
  end
end
