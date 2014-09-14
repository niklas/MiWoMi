Miwomi::Finder.insert do
  attribute :klass

  match_value do |source, candidate|
    source == candidate
  end
end
