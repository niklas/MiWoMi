Miwomi::Finder.insert do
  attribute :descriptive_name
  weight 5

  words do |value|
    value.underscore.scan(/\b\w+\b/i).reverse
  end

  match_word do |word, value|
    value.downcase.include?(word)
  end
end

