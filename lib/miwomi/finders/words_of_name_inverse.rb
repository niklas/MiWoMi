Miwomi::Finder.insert do
  source_attribute :descriptive_name
  candidate_attribute :name_words
  weight 8

  match_value do |mine, theirs|
    theirs.any? do |t|
      !!(/\b#{t}\b/i).match(mine)
    end
  end
end

