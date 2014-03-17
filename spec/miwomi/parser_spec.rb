require 'miwomi'

describe Miwomi::Parser do
  describe '.parse_file' do
    let(:parsed) { double 'Collection' }

    it 'detects old NEI dumps from .txt extension' do
      filename = "ID dump.txt"

      parser = double 'DumpParser'
      Miwomi::DumpParser.stub(new: parser)
      parser.should_receive(:parse_file).with(filename).and_return(parsed)

      described_class.parse_file(filename).should == parsed
    end

    it 'detects new NEI dumps from .csv extension' do
      filename = "ID dump.csv"

      parser = double 'CsvParser'
      Miwomi::CsvParser.stub(new: parser)
      parser.should_receive(:parse_file).with(filename).and_return(parsed)

      described_class.parse_file(filename).should == parsed
    end
  end
end
