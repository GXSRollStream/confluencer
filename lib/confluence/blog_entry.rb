module Confluence
  class BlogEntry < Record
    extend Findable
    
    record_attr_accessor :id => :entry_id
    record_attr_accessor :space
    record_attr_accessor :title, :content
    record_attr_accessor :publishDate
    record_attr_accessor :url
  
    def store
      # reinitialize blog entry after storing it
      initialize(client.storeBlogEntry(self.to_hash))
    end
  
    def remove
      client.removePage(self.entry_id)
    end
    
    private
        
    def self.find_criteria(args)
      if args.key? :id
        self.new(client.getBlogEntry(args[:id]))
      elsif args.key? :space
        client.getBlogEntries(args[:space]).collect { |summary| BlogEntry.find(:id => summary["id"]) }
      end
    end
  end
end