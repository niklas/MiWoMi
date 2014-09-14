require 'spec_helper'

describe StubbedFactorySpecHelpers do
  context '#thing' do
    context 'only id given' do
      subject { thing(23) }

      it 'builds just from id' do
        subject.id.should == 23
      end
    end

    context 'id and hash given' do
      subject { thing(23, name: 'air') }

      it 'uses id' do
        subject.id.should == 23
      end

      it 'uses other attributes from hash' do
        subject.name.should == 'air'
      end

      it 'can overwrite id from hash' do
        thing(23, id: 42).id.should == 42
      end
    end

    context 'only hash given' do
      subject { thing id: 23, name: 'air' }
      it 'uses id from hash' do
        subject.id.should == 23
      end

      it 'uses other attributes from hash' do
        subject.name.should == 'air'
      end
    end
  end
end
