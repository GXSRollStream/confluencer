require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Confluence::Page::Details do
  it "should initialize with a label" do
    details = Confluence::Page::Details.new :label => :confluencer
    details.label.should == :confluencer
  end
  
  it "should return {details} macro" do
    details = Confluence::Page::Details.new :label => :confluencer
    details[:creator] = "rgabo"
    
    details.to_s.should == <<-DETAILS
{details:label=confluencer}
creator:rgabo
{details}
DETAILS
  end
  
  it "should initialize with macro content" do
    details = Confluence::Page::Details.new :content => <<-DETAILS
{details:label=confluencer}
creator:rgabo
{details}
DETAILS

    details.label.should == "confluencer"
    details[:creator].should == "rgabo"
  end
end

describe Confluence::Page::DetailsCollection do
  it "should scan content for details" do
    hash = Confluence::Page::DetailsCollection.new <<-CONTENT
{details:label=confluencer}
creator:rgabo
{details}

{details:label=ruby}
creator=matz
{details}
CONTENT

    hash.should include(:confluencer)
  end
end

describe Confluence::Page do
  include PageHelperMethods
  
  it "should add a new page in Confluence" do
    new_session do
      # initialize test page
      page = create_test_page
      
      # page_id should be nil
      page.page_id.should be_nil
      
      # store page
      page.store
      
      # check page_id
      page.page_id.should_not be_nil

      # find page by id
      new_page = Confluence::Page.find :id => page.page_id
      
      # assert page
      new_page.should_not be_nil
      new_page.title.should == page.title
      
      # remove page
      new_page.remove
    end
  end
  
  it "should update an existing page in Confluence by id" do
    with_test_page do |page|
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
    with_test_page do |page|
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
  
  it "should keep metadata for the page" do
    page = create_test_page
    
    # set :creator in {details:label=bender} to 'rgabo'
    page.details[:confluencer][:creator] = 'rgabo'
  
    page.details[:confluencer][:creator].should == 'rgabo'
  end
  
  it "should include metadata in content of the page" do
    page = create_test_page

    # set :creator in {details:label=bender} to 'rgabo'
    page.details[:confluencer][:creator] = 'rgabo'
          
    page.to_hash['content'].should include("{details:label=confluencer}\ncreator:rgabo\n{details}")
  end
  
  it "should copy metadata from one page to another" do
    page = create_test_page
    page.details[:confluencer][:creator] = 'rgabo'
    
    new_page = create_test_page
    new_page.details = page.details
    
    new_page.details[:confluencer][:creator].should == 'rgabo'
  end
  
  it "should parse metadata from content" do
    page = Confluence::Page.new "content" => "{details:label=confluencer}\ncreator:rgabo\n{details}\nh3. Some other content"
    
    page.details[:confluencer][:creator].should == "rgabo"
  end
  
  it "should add an attachment" do
    with_test_page do |page|
      page.add_attachment(File.basename(__FILE__), "text/plain", IO.read(__FILE__), "test attachment comment")
      
      page.attachments.count.should == 1
      
      attachment = page.attachments.first
      
      attachment.should_not be_nil
      attachment.url.should_not be_nil
      attachment.data.should == IO.read(__FILE__)
    end
  end
end

