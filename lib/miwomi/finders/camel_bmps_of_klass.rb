Miwomi::Finder.insert do
  words do |value|
    value.
      underscore.
      scan(/[[:alnum:]]+/i).
      map(&:downcase).
      reverse
  end

  attribute :descriptive_klass

  match_word do |word, value|
    value.downcase.include?(word)
  end
end

