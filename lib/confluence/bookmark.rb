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
      
      if content
        # if no bookmark_url from hash, initialize from content
        unless @bookmark_url
          @bookmark_url = content[BOOKMARK_URL_REGEXP, 1]
          @description = content[DESCRIPTION_REGEXP, 1]
        end
      
        # remove {bookmark} macro from content
        content.gsub!(BOOKMARK_REGEXP, "")
      end
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

      page_hash["content"] << "\n" unless page_hash["content"].empty?
      page_hash["content"] << bookmark_content
      
      page_hash
    end
    
    private
    
    def bookmark_content
      "{bookmark:url=#{@bookmark_url}}#{@description}{bookmark}"
    end
    
    def self.find_criteria(args)
      result = super(args) || begin
        if args.key? :space
          space = Space.find :key => args[:space]
          space.bookmarks
        end
      end
      
      result
    end
  end
end