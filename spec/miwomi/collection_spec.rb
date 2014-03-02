require 'miwomi/collection'

describe Miwomi::Collection do
  describe '#add_thing' do
    it 'can add a Block' do
      expect {
        subject.add_thing 'Block', 23, 'mine'
      }.to change { subject.length }.from(0).to(1)
      subject.first.tap do |b|
        b.should be_block
        b.id.should == 23
        b.name.should == 'mine'
      end
    end

    it 'can add an Item' do
      expect {
        subject.add_thing 'item', 42, 'tile.answer'
      }.to change { subject.length }.from(0).to(1)
      subject.first.tap do |b|
        b.should be_item
        b.id.should == 42
        b.name.should == 'tile.answer'
      end
    end
  end

  describe '#find_by_id' do
    it 'can find item by id' do
      subject << (bad1 = double 'Bad1', id: 22)
      subject << (bad2 = double 'Bad2', id: 42)
      subject << (good = double 'Good', id: 23)
      subject << (bad3 = double 'Bad3', id: 44)
      subject << (bad4 = double 'Bad4', id: 12)

      subject.find_by_id(23).should == good
    end
  end
end
