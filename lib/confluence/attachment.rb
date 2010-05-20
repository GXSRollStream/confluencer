module Confluence
  class Attachment < Record
    extend Findable
    
    record_attr_accessor :id => :attachment_id
    record_attr_accessor :pageId => :page_id
    record_attr_accessor :fileName => :filename
    record_attr_accessor :fileSize => :filesize
    record_attr_accessor :contentType => :content_type
    record_attr_accessor :title, :creator, :created, :url, :comment
    
    attr_writer :data
    
    def data
      @data ||= client.getAttachmentData(page_id, filename, "0")
    end
    
    def store
      # reinitialize attachment after storing it
      initialize(client.addAttachment(page_id, self.to_hash, XMLRPC::Base64.new(@data)))
      
      # return self
      self
    end
    
    def remove
      client.removeAttachment(page_id, filename)
    end
        
    def self.find_criteria(args)
      if args.key? :page_id and args.key? :filename
        self.new(client.getAttachment(args[:page_id], args[:filename], args[:version] || "0"))
      end
    end
  end
end
