module Confluence
  # A Confluence space.
  class Space < Record
    extend Findable
    
    BOOKMARKS_PAGE_TITLE = ".bookmarks"
    
    record_attr_accessor :key, :name, :url, :description
    record_attr_accessor :homePage => :homepage
    
    def bookmark_page
      @bookmark_page ||= Page.find :space => self.key, :title => BOOKMARKS_PAGE_TITLE
    end
    
    def bookmarks
      @bookmarks ||= bookmark_page ? bookmark_page.children(Bookmark) : []
    end
    
    def blog_entries
      client.getBlogEntries(self.key).collect {|summary| BlogEntry.new(client.getBlogEntry(summary["id"]))}
    end
    
    def find_page(args)
      if args.key? :title
        Page.find :space => self.key, :title => args[:title]
      end
    end
    
    private
    
    def self.find_all
      client.getSpaces.collect { |summary| Space.find(:key => summary["key"]) }
    end
    
    def self.find_criteria(args)
      if args.key? :key
        Space.new(client.getSpace(args[:key]))
      end
    end
  end
end
