require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Confluence::User do
  include SessionHelperMethods
  
  it "should find all users" do
    new_session do
      users = Confluence::User.find :all
      users.should_not be_empty
    end
  end
  
  it "should find a user by its name" do
    new_session do
      # find all users
      users = Confluence::User.find :all
      
      # find first user by name
      first_user = Confluence::User.find :name => users.first.name
      
      first_user.name.should == users.first.name
    end
  end
end
