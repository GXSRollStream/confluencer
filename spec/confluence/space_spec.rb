require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Confluence::Space do
  include SessionHelperMethods

  def test_space
    @test_space ||= Confluence::Space.find(:key => config[:space])
  end
  
  it "should find all spaces" do
    new_session do
      spaces = Confluence::Space.find(:all)
    
      spaces.should_not be_empty
    end
  end
  
  it "should find a space by its key" do
    new_session do
      space = Confluence::Space.find(:key => config[:space])
      
      space.should_not be_nil
      space.key.should == config[:space]
    end
  end
  
  it "should find a page in the space" do
    new_session do
      page = test_space.find_page :title => "Home"
      
      page.should_not be_nil
      page.space.should == test_space.key
    end
  end
  
  it "should return all bookmarks in the space" do
    new_session do
      # create a bookmark in the test_space
      bookmark = Confluence::Bookmark.new :space => test_space.key, :title => "Atlassian", :bookmark_url => "http://atlassian.com"
      bookmark.store
      
      bookmarks = test_space.bookmarks
      bookmarks.should_not be_empty

      # delete test bookmark
      bookmark.remove
    end
  end
end
