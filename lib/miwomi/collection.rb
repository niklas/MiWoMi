module Miwomi
  class Collection < Array

    def find_by_id(want)
      find { |x| x.id == want }
    end

  end
end
