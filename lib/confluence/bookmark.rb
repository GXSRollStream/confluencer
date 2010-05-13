module Confluence
  class Bookmark < Page
    attr_accessor :bookmark_url, :description

    BOOKMARK_REGEXP = /\{bookmark.*\}[^\{]*\{bookmark\}/
    BOOKMARK_URL_REGEXP = /\{bookmark:url=([^\}]+)\}/
    DESCRIPTION_REGEXP = /\{bookmark.*\}([^\{]*)\{bookmark\}/
    
    def initialize(hash)
      # set and delete bookmark_url and description coming from hash
      @bookmark_url = hash.delete :bookmark_url
      @description = hash.delete :description
      
      # initialize page
      super(hash)
      
      # if no bookmark_url from hash, initialize from content
      unless @bookmark_url
        @bookmark_url = content[/\{bookmark:url=([^\}]+)\}/, 1]
        @description = content[/\{bookmark.*\}([^\{]*)\{bookmark\}/, 1]
      end
      
      # remove {bookmark} macro from content
      content.gsub!(BOOKMARK_REGEXP, "") if content
    end
    
    def [](attr)
      case attr
      when :bookmark_url: @bookmark_url
      when :description: @description
      else
        super(attr)
      end
    end
    
    def []=(attr, value)
      case attr
      when :bookmark_url: @bookmark_url = value
      when :description: @description = value
      else
        super(attr, value)
      end
    end
    
    def store
      # always set .bookmarks as the parent page
      self.parent_id = Page.find(:space => space, :title => Space::BOOKMARKS_PAGE_TITLE).page_id
      
      # continue with storing the page
      super
    end
    
    def to_hash
      page_hash = super

      if page_hash.key? "content"
        page_hash["content"] << "\n" << bookmark_content
      else
        page_hash["content"] = bookmark_content
      end
      
      page_hash
    end
    
    private
    
    def bookmark_content
      "{bookmark:url=#{@bookmark_url}}#{@description}{bookmark}"
    end
    
    def self.find_criteria(args)
      result = super(args) || begin
        if args.key? :space
          space = Space.find :space => args[:space]
          space.bookmarks
        end
      end
      
      result
    end
  end
end