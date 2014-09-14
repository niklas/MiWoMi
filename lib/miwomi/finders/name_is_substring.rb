Miwomi::Finder.insert do
  attribute :descriptive_name
  weight 4

  match_value do |mine, theirs|
    mine.scan(/\b\w+\b/i).any? do |t|
      mine.downcase.include?(t.downcase)
    end
  end
end

