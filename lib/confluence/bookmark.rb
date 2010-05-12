module Confluence
  class Bookmark < Page
    attr_reader :bookmark_url, :description

    def initialize(hash)
      super(hash)
      
      # if no content, try to use hash to initialize, delete in the process
      unless content
        self.bookmark_url = attributes.delete :bookmark_url
        self.description = attributes.delete :description
      else
        # parse bookmark_url and description out of content
        @bookmark_url = content[/\{bookmark:url=([^\}]+)\}/, 1]
        @description = content[/\{bookmark.*\}([^\{]*)\{bookmark\}/, 1]
      end
    end
    
    def bookmark_url=(value)
      @bookmark_url = value
      
      # update content with new bookmark_url
      update_content
    end
    
    def description=(value)
      @description = value

      # update content with new description
      update_content
    end
    
    def store
      # always set .bookmarks as the parent page
      self.parent_id = Page.find(:space => space, :title => Space::BOOKMARKS_PAGE_TITLE).page_id
      
      # continue with storing the page
      super
    end
    
    private
    
    def self.find_criteria(args)
      result = super(args) || begin
        if args.key? :space
          space = Space.find :space => args[:space]
          space.bookmarks
        end
      end
      
      result
    end
    
    def update_content
      self.content = "{bookmark:url=#{@bookmark_url}}#{@description}{bookmark}"
    end
  end
end