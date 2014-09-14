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
      subject.stub klass: 'common.blocks.BlockAdv'
      subject.descriptive_klass.should_not =~ /block/i
    end
  end

end
