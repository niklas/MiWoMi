Miwomi::Finder.insert do
  attribute :descriptive_name
  weight 4

  words do |value|
    value.underscore.scan(/\b\w+\b/i).reverse
  end

  match_word do |word, value|
    !!(/\b#{word}\b/i).match(value)
  end
end

