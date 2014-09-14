Miwomi::Finder.insert do
  attribute :name
  weight 2

  words do |value|
    value.gsub(/ore/i, '').scan(/\w+/i).reverse
  end

  match_word do |word, value|
    value.downcase.include?(word)
  end

end
