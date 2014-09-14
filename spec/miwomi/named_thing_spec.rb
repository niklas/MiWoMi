require 'spec_helper'

describe Miwomi::NamedThing do
  subject { described_class.new 23, 'thename' }

  context '#descriptive_name' do
    it 'does not change already minimal name' do
      subject.stub name: 'dwarfhouse'
      subject.descriptive_name.should == 'dwarfhouse'
    end

    it 'removes mod namespace' do
      subject.stub name: 'Yogscraft:dwarfhouse'
      subject.descriptive_name.should == 'dwarfhouse'
    end

    it 'removes kill words' do
      subject.stub name: 'Panel:BlockAdv'
      subject.descriptive_name.should_not =~ /block/i
    end
  end

  context '#descriptive_klass' do
    it 'removes minecraft class hierarchy' do
      subject.stub klass: 'net.minecraft.block.dwarf'
      subject.descriptive_klass.should == 'dwarf'
    end

    it 'removes kill words' do
      subject.stub klass: 'common.block.BlockAdv'
      subject.descriptive_klass.should_not =~ /block/i
      subject.descriptive_klass.should_not include('..')
    end

    it 'removes kill word plurals' do
      subject.stub klass: 'common.blocks.BlockAdv'
      subject.descriptive_klass.should_not =~ /block/i
      subject.descriptive_klass.should_not include('.s.')
      subject.descriptive_klass.should_not include('..')
    end

    it 'removes surrounding dots from kill worlds' do
      subject.stub klass: 'lapis.block'
      subject.descriptive_klass.should == 'lapis'
    end

    it 'removes surrounding underscores from kill worlds' do
      subject.stub klass: 'lapis_block'
      subject.descriptive_klass.should == 'lapis'
    end
  end

end
