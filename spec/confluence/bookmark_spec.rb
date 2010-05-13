require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Confluence::Bookmark do
  it "should initialize bookmark_url and description from hash" do
    bookmark = Confluence::Bookmark.new :bookmark_url => 'http://github.com/rgabo/confluencer', :description => 'Home sweet home'
    
    bookmark.bookmark_url.should == 'http://github.com/rgabo/confluencer'
    bookmark.description.should == 'Home sweet home'
  end
  
  it "should initialize bookmark_url and descrition from content" do
    bookmark = Confluence::Bookmark.new "content" => "{bookmark:url=http://github.com/rgabo/confluencer}Home sweet home{bookmark}"
    
    bookmark.bookmark_url.should == 'http://github.com/rgabo/confluencer'
    bookmark.description.should == 'Home sweet home'
    
    bookmark.content.should_not include "bookmark"
  end
  
  it "should get and set bookmark_url and description using #[]" do
    bookmark = Confluence::Bookmark.new :bookmark_url => 'http://github.com/rgabo/confluencer', :description => 'Home sweet home'

    # bookmark_url and description should not be available as ordinary attributes in the hash
    bookmark[:bookmark_url].should == 'http://github.com/rgabo/confluencer'
    bookmark[:description].should == 'Home sweet home'
    
    bookmark[:bookmark_url] = 'http://github.com/rgabo'
    bookmark[:description] = 'rgabo @ Github'
    
    bookmark[:bookmark_url].should == 'http://github.com/rgabo'
    bookmark[:description].should == 'rgabo @ Github'

    bookmark.bookmark_url.should == 'http://github.com/rgabo'
    bookmark.description.should == 'rgabo @ Github'
  end
  
  it "should not include bookmark_url and description in to_hash" do
    bookmark = Confluence::Bookmark.new :bookmark_url => 'http://github.com/rgabo/confluencer', :description => 'Home sweet home', :title => "Page title"
    
    bookmark.to_hash.key?('bookmark_url').should be_false
    bookmark.to_hash.key?('description').should be_false
    bookmark.to_hash.key?('title').should be_true
  end
end