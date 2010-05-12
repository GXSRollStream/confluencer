require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Confluence::Record do
  it "should store the client" do
    Confluence::Record.client = 'client'
    
    Confluence::Record.client.should == 'client'
    Confluence::Record.new.client.should == 'client'
  end
  
  it "should initialize new record from hash" do
    record = Confluence::Record.new(:foo => 'bar', 'string' => 'works')
    
    record[:foo].should == 'bar'
    record[:string].should == 'works'
  end
  
  it "should return the id of the record" do
    record = Confluence::Record.new 'id' => '12345'
    
    record.record_id.should == '12345'
  end
end
