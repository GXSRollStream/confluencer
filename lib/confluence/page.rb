module Confluence
  class Page < Record
    extend Findable
    
    record_attr_accessor :id => :page_id
    record_attr_accessor :parentId => :parent_id
    record_attr_accessor :space
    record_attr_accessor :title, :creator, :modifier, :content
    record_attr_accessor :created, :modified, :version
    record_attr_accessor :url
            
    def children(klass = self.class)
      children = client.getChildren(page_id)
      children.collect { |child| klass.find(:id => child["id"]) } if children
    end
    
    def store
      unless self.version
        # check for existing page by id or title
        existing_page = if page_id
          Page.find :id => page_id
        else
          Page.find :space => space, :title => title
        end
        
        # take page_id and version from existing page if available
        if existing_page
          self.page_id = existing_page.page_id
          self.version = existing_page.version
        end
      end
      
      # reinitialize page after storing it
      initialize(client.storePage(attributes))
      
      # return self
      self
    end
    
    def remove
      client.removePage(page_id)
    end
    
    private
    
    def self.find_all
      raise ArgumentError, "Cannot find all pages, find by id or title instead."
    end
    
    def self.find_criteria(args)
      if args.key? :id
        self.new(client.getPage(args[:id]))
      elsif args.key?(:space) && args.key?(:title)
        self.new(client.getPage(args[:space], args[:title]))
      end
    end
  end
end