Miwomi::Finder.insert do
  source_attribute :klass_word
  candidate_attribute :descriptive_klass
  weight 3

  match_value do |words, their|
    words.any? do |t|
      !!(/\b#{t}\b/i).match(their)
    end
  end
end
