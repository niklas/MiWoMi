require 'miwomi/csv_parser'

describe Miwomi::CsvParser do
  describe '.parse_file' do
    let(:direwolf_file) { File.expand_path '../../fixtures/direwolf20-1.6.4.csv', __FILE__ }
    it 'parses Direwolf20_1_6_4 csv dump' do
      results = subject.parse_file direwolf_file
      results.should have_at_least(200).items

      results.find_by_id(7).name.should == 'tile.bedrock'
      results.find_by_id(8).name.should == 'tile.water'
      results.find_by_id(200).should be_nil
    end
  end
end
