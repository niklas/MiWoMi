Miwomi::Finder.insert do
  attribute :descriptive_klass
  weight 9

  match_value do |source, candidate|
    source.downcase == candidate.downcase
  end
end
