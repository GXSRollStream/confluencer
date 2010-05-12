require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Confluence::Page do
  include SessionHelperMethods
  
  def create_test_page(content = "foobar")
    Confluence::Page.new :space => config[:space], :title => config[:page_title], :content => content
  end
  
  def store_test_page
    new_session do
      return create_test_page.store
    end
  end
  
  after :each do
    new_session do
      begin
        # check whether we need to remove the test page
          test_page = Confluence::Page.find :space => config[:space], :title => config[:page_title]
        test_page.remove if test_page
      rescue Confluence::Error
      end
    end    
  end
  
  it "should add a new page in Confluence" do
    page = nil
    
    new_session do
      # initialize test page
      page = create_test_page
      
      # page_id should be nil
      page.page_id.should be_nil
      
      # store page
      page.store
      
      # check page_id
      page.page_id.should_not be_nil
    end

    # initialize new session
    new_session do
      # find page by id
      new_page = Confluence::Page.find :id => page.page_id
      
      # assert page
      new_page.should_not be_nil
      new_page.title.should == page.title
    end
  end
  
  it "should update an existing page in Confluence by id" do
    page = store_test_page
    
    new_session do
      # create test page with same id but updated content
      updated_page = create_test_page "updated content"

      updated_page.page_id = page.page_id
      
      # store page
      updated_page.store
      
      # assert version
      updated_page.version.should > page.version
      updated_page.content.should == "updated content"
    end
  end
  
  it "should update an existing page in Confluence by space and title" do
    page = store_test_page
    
    new_session do
        # create test page with same title but updated content
        updated_page = create_test_page "updated content"

        updated_page.page_id.should be_nil
        updated_page.title.should == page.title
        updated_page.space.should == page.space

        # store page
        updated_page.store

        # assert version
        updated_page.version.should > page.version
        updated_page.content.should == "updated content"
      end      
  end
end
