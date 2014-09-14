Miwomi::Finder.insert do
  source_attribute :klass_words
  candidate_attribute :descriptive_klass
  weight 1

  match_value do |words, value|
    words.any? do |word|
      value.downcase.include?(word)
    end
  end
end
