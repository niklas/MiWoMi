Miwomi::Finder.insert do
  attribute :descriptive_klass

  words do |value|
    value.scan(/\w+/i).reverse
  end

  match_word do |word, value|
    !!(/\b#{word}\b/i).match(value)
  end
end
