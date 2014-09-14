Miwomi::Finder.insert do
  attribute :name

  match_value do |source, candidate|
    options.alternatives.any? do |original, alt|
      source.include?(original) &&
        candidate.downcase == source.downcase.gsub(Regexp.new(original), alt)
    end
  end
end

