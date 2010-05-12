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
  
  it "should return attribute values" do
    record = Confluence::Record.new(:key => 'value', 'string_key' => 'string_value')
    
    record[:key].should == 'value'
    record[:string_key].should == 'string_value' # attributes with string keys should be accessible with symbols
  end
  
  it "should set attribute values" do
    record = Confluence::Record.new
    record[:key] = 'value'
    
    record[:key].should == 'value'
  end
  
  it "should return the id of the record" do
    record = Confluence::Record.new 'id' => '12345'
    
    record.record_id.should == '12345'
  end
  
  it "should return a string-keyed hash of its attributes" do
    record = Confluence::Record.new :key => 'value'
    
    record.to_hash.should == {'key' => 'value'}
  end
end
