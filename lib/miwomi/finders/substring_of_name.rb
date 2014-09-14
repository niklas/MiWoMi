Miwomi::Finder.insert do
  source_attribute :name_words
  candidate_attribute :descriptive_name
  weight 5

  match_value do |words, value|
    words.any? do |word|
      value.downcase.include?(word)
    end
  end
end

