Miwomi::Finder.insert do
  source_attribute :name
  candidate_attribute :name_without_namespace

  match_value do |source, candidate|
    source == candidate
  end
end

