require 'miwomi/dump_parser'

describe Miwomi::DumpParser do

  describe '#parse' do
    it 'detects Block' do
      result = subject.parse BlockDump
      result.should have(5).items
      result.map(&:id).should == [1,2,3,4,14]
      result.map(&:name).should == [
        'tile.stone',
        'tile.grass',
        'tile.dirt',
        'tile.stonebrick',
        'Dwarf Gold',
      ]
    end

    it 'detects Item' do
      result = subject.parse ItemDump
      result.should have(5).items
      result.map(&:id).should == [256,257,258,259, 281]
      result.map(&:name).should == [
        'item.shovelIron',
        'item.pickaxeIron',
        'item.hatchetIron',
        'Fire Starter',
        'item.bowl',
      ]
    end

    it 'ignores Unused things' do
      subject.parse( UnusedDump ).should be_empty
    end

    it 'complains about bad lines' do
      expect {
        subject.parse "Trololol. Game: lost\n"
      }.to raise_error(described_class::BadLine)
    end

    let(:yogcraft_file) { File.expand_path '../../fixtures/yogcraft-1.0.neidump', __FILE__ }
    it 'parses YogCraft-1.0 NEI dump' do
      subject.parse_file yogcraft_file
    end
  end
end

BlockDump = <<-EODUMP
Block. Name: tile.stone. ID: 1
Block. Name: tile.grass. ID: 2
Block. Name: tile.dirt. ID: 3
Block. Name: tile.stonebrick. ID: 4
Block. Name: Dwarf Gold. ID: 14
EODUMP

ItemDump = <<-EODUMP
Item. Name: item.shovelIron. ID: 256
Item. Name: item.pickaxeIron. ID: 257
Item. Name: item.hatchetIron. ID: 258
Item. Name: Fire Starter. ID: 259
Item. Name: item.bowl. ID: 281
EODUMP

UnusedDump = <<-EODUMP
Block. Unused ID: 404
Item. Unused ID: 4100
EODUMP
