Miwomi::Finder.insert do
  attribute :id
  weight 3 # actually quiet desperate, other things should match, too

  match_value do |source, candidate|
    source == candidate
  end
end

