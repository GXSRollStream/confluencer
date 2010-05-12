require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Confluence::Session do
  include ConfigurationHelperMethods
  
  it "should log into Confluence and have valid token" do
    session = Confluence::Session.new config
    
    session.client.should_not be_nil
    session.token.should_not be_nil
  end
  
  it "should log out of Confluence and invalidate token" do
    session = Confluence::Session.new config

    # destroy session
    session.destroy
    
    session.client.should be_nil
    session.token.should be_nil
  end
  
  it "should yield the client and log out of Confluence if a block is given" do
    session = Confluence::Session.new(config) do |client|
      client.should_not be_nil
      client.token.should_not be_nil
    end
    
    session.client.should be_nil
    session.token.should be_nil
  end
end