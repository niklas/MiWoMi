Miwomi::Finder.insert do
  attribute :descriptive_name
  weight 8

  match_value do |mine, theirs|
    mine.scan(/\w+/i).any? do |t|
      !!(/\b#{t}\b/i).match(mine)
    end
  end
end

