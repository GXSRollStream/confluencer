require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Confluence::Client do
  include ConfigurationHelperMethods
  
  def new_client_from_config
    Confluence::Client.new(config)
  end
  
  def logged_in_client
    client = new_client_from_config
    client.login(config[:username], config[:password])
    client.has_token?.should be_true
    client
  end
  
  it "can initialize a client with a url" do
    client = Confluence::Client.new :url => "http://confluence.atlassian.com"
    
    client.should_not be_nil
    client.url.should_not be_nil
    client.url.should == "http://confluence.atlassian.com"
  end
  
  it "can initialize a client with an existing token" do
    client = Confluence::Client.new :url => "http://confluence.atlassian.com", :token => "abcdef"
    client.token.should_not be_nil
    client.token.should == "abcdef"
  end
  
  it "can return whether a token is already available" do
    client = Confluence::Client.new :url => "http://confluence.atlassian.com"
    client.has_token?.should be_false
    
    client = Confluence::Client.new :url => "http://confluence.atlassian.com", :token => "abcdef"
    client.has_token?.should be_true
  end
  
  it "can log in and acquire a session token" do
    client = new_client_from_config
    client.has_token?.should be_false
    
    token = client.login(config[:username], config[:password])
    token.should_not be_nil
    
    client.has_token?.should be_true
    client.token.should == token
  end
  
  it "raises an error if it cannot login" do
   client = new_client_from_config
   
   lambda { client.login(config[:username], "bogus") }.should raise_exception(Confluence::Error, /incorrect password/)
   client.has_token?.should be_false
   
   lambda { client.login("bogus", "bogus") }.should raise_exception(Confluence::Error, /no user could be found/)
   client.has_token?.should be_false
  end
  
  it "can logout and invalidate a session token" do
    client = logged_in_client
    
    client.logout.should be_true
    client.has_token?.should be_false
  end
  
  it "can make XMLRPC calls" do
    client = logged_in_client
    
    server_info = client.getServerInfo
    server_info.should_not be_nil
    server_info["baseUrl"].should == client.url
  end
end