require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Confluence::Attachment do
  include PageHelperMethods

  FILENAME = File.basename(__FILE__)
  
  it "should store an attachment" do
    with_test_page do |page|
      attachment = Confluence::Attachment.new :pageId => page.page_id, :fileName => FILENAME, :contentType => "text/plain", :comment => "Test upload"
      attachment.data = IO.read(__FILE__)
      attachment.store
      
      attachment.attachment_id.should_not be_nil
      attachment.filesize.should_not be_nil
      attachment.url.should_not be_nil
    end
  end
  
  it "should find an attachment and get its data" do
    with_test_page do |page|
      attachment = Confluence::Attachment.new :pageId => page.page_id, :fileName => FILENAME, :contentType => "text/plain", :comment => "Test upload"
      attachment.data = IO.read(__FILE__)
      attachment.store

      attachment = Confluence::Attachment.find :page_id => page.page_id, :filename => FILENAME
      attachment.should_not be_nil
      attachment.filename.should == FILENAME
      attachment.data.should == IO.read(__FILE__)
    end    
  end
  
  it "should remove an attachment" do
    with_test_page do |page|
      attachment = Confluence::Attachment.new :pageId => page.page_id, :fileName => FILENAME, :contentType => "text/plain", :comment => "Test upload"
      attachment.data = IO.read(__FILE__)
      attachment.store
      
      # remove attachment
      attachment.remove
      
      # should not be able to find attachment
      Confluence::Attachment.find(:page_id => page.page_id, :filename => FILENAME).should be_nil
    end
  end
end