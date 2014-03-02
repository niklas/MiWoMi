require 'miwomi/collection'

describe Miwomi::Collection do
  describe '#find_by_id' do
    it 'can find item by id' do
      subject << (bad1 = mock 'Bad1', id: 22)
      subject << (bad2 = mock 'Bad2', id: 42)
      subject << (good = mock 'Good', id: 23)
      subject << (bad3 = mock 'Bad3', id: 44)
      subject << (bad4 = mock 'Bad4', id: 12)

      subject.find_by_id(23).should == good
    end
  end
end
