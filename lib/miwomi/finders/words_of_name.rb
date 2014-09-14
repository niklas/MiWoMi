Miwomi::Finder.insert do
  source_attribute :name_words
  candidate_attribute :descriptive_name
  weight 6

  match_value do |words, value|
    words.any? do |word|
      !!(/\b#{word}\b/i).match(value)
    end
  end
end

