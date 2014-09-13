Miwomi::Finder.insert do
  words do
    source.
      klass.
      underscore.
      scan(/[[:alnum:]]+/i).
      map(&:downcase).
      reverse
  end

  attribute :klass

  match_word do |word, value|
    value.downcase.include?(word)
  end
end

