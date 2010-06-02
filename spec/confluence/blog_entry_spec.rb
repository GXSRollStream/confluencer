require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Confluence::BlogEntry do
  include SessionHelperMethods
  
  after(:each) do
    new_session do
      Confluence::BlogEntry.find(:space => config[:space]).each do |blog_entry|
        blog_entry.remove
      end
    end
  end
  
  def create_test_entry
    Confluence::BlogEntry.new :space => config[:space], :title => config[:entry_title], :content => "foobar"
  end

  
  it "should add a new blog entry to Confluence" do
    new_session do
      # create blog entry
      # with_discardable_blog_entry :space => config[:space] do |blog_entry|
      #   
      # end
         
      blog_entry = create_test_entry
      
      blog_entry.entry_id.should be_nil

      # store blog entry
      blog_entry.store
      
      # verify blog entry was stored
      blog_entry.entry_id.should_not be_nil
      blog_entry.url.should_not be_nil
    end
  end

  it "should find a blog entry in Confluence by id" do
    new_session do
      # create blog entry
      blog_entry = create_test_entry
    
      # store blog entry
      blog_entry.store
    
      # store entry_id
      @entry_id = blog_entry.entry_id
    end

    new_session do
      blog_entry = Confluence::BlogEntry.find :id => @entry_id
      
      blog_entry.should_not be_nil
      blog_entry.entry_id.should == @entry_id
      blog_entry.content.should == "foobar"
    end
  end

  it "should find all blog entries in Confluence" do
    new_session do
      # create blog entry
      blog_entry = create_test_entry
  
      # store blog entry
      blog_entry.store
    end
    
    new_session do
      blog_entries = Confluence::BlogEntry.find :space => config[:space]
      
      blog_entries.should_not be_nil
      blog_entries.should_not be_empty
    end
  end
  
  it "should remove a blog entry from Confluence" do
    new_session do
      # create blog entry
      blog_entry = create_test_entry

      # store blog entry
      blog_entry.store
      
      # store entry_id
      @entry_id = blog_entry.entry_id
      
      # remove blog entry
      blog_entry.remove.should be_true
    end
  end
end