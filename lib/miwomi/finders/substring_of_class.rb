Miwomi::Finder.insert do
  attribute :descriptive_klass
  weight 1

  words do |value|
    value.scan(/\w+/i).reverse
  end

  match_word do |word, value|
    value.downcase.include?(word)
  end
end
