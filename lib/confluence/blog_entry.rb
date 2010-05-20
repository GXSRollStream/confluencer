module Confluence
  class BlogEntry < Record
    extend Findable
    
    record_attr_accessor :id => :entry_id
    record_attr_accessor :space
    record_attr_accessor :title, :content
    record_attr_accessor :publishDate
    record_attr_accessor :url
  
    private
        
    def self.find_criteria(args)
      if args.key? :id
        self.new(client.getBlogEntries(args[:id]))
      end
    end
  end
end