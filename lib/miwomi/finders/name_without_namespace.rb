Miwomi::Finder.insert do
  source_attribute :descriptive_name
  candidate_attribute :name_without_namespace
  weight 2

  match_value do |source, candidate|
    source == candidate
  end
end

