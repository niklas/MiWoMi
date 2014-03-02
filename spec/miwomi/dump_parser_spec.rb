require 'miwomi/dump_parser'

describe Miwomi::DumpParser do

  describe '#parse' do
    it 'detects blocks' do
      result = subject.parse BlockDump
      result.should have(5).items
    end

    it 'complains about bad lines' do
      expect {
        subject.parse "Trololol. Game: lost\n"
      }.to raise_error(described_class::BadLine)
    end
  end
end

BlockDump = <<-EODUMP
Block. Name: tile.stone. ID: 1
Block. Name: tile.grass. ID: 2
Block. Name: tile.dirt. ID: 3
Block. Name: tile.stonebrick. ID: 4
Block. Name: tile.wood. ID: 5
EODUMP
