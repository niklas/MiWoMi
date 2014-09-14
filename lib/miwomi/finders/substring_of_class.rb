Miwomi::Finder.insert do
  attribute :name

  words do |value|
    value.scan(/\w+/i).reverse
  end

  match_word do |word, value|
    value.downcase.include?(word)
  end
end
