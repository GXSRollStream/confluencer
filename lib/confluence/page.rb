module Confluence
  class Page < Record
    INVALID_TITLE_CHARS = ":@/\\|^#;[]{}<>"
    
    class Details < Hash
      REGEXP = /\{details:label=([^\}]+)\}([^\{}]*)\{details\}/m
      PAIR_REGEXP = /([^:]+):([^\n]+)/m
      
      attr_reader :label
      
      def initialize(args)
        @label = args[:label]
        
        parse(args[:content])
      end
            
      def to_s
        # details macro
        content = "{details:label=#{label}}\n"
        
        each_pair do |key, value|
          content << "#{key}:#{value}\n"
        end
        
        # end of details macro
        content << "{details}\n"
      end
      
      private
      
      def parse(content)
        if content && content =~ REGEXP
          # match label and the key/value pairs
          @label, pairs = content.match(REGEXP).captures
        
          pairs.strip.lines.each do |line|
            if line =~ PAIR_REGEXP
              self[$1.to_sym] = $2.strip
            end
          end
        end
      end
    end
    
    class DetailsCollection < Hash
      def initialize(content)
        if content
          content.gsub!(Details::REGEXP) do |content|
            self[$1.to_sym] = Details.new(:content => content)
            ""
          end
        end
      end
      
      def [](key)
        super(key) or self[key] = Details.new(:label => key)
      end
      
      def to_s
        values.join("\n")
      end
    end  
    
    extend Findable
    
    record_attr_accessor :id => :page_id
    record_attr_accessor :parentId => :parent_id
    record_attr_accessor :space
    record_attr_accessor :title, :creator, :modifier, :content
    record_attr_accessor :created, :modified, :version
    record_attr_accessor :url

    attr_accessor :details
    
    def initialize(hash)
      super(hash)

      @details = DetailsCollection.new(content)
    end
        
    def children(klass = self.class)
      children = client.getChildren(page_id)
      children.collect { |child| klass.find(:id => child["id"]) } if children
    end
    
    def store(args = {})
      unless self.version
        # check for existing page by id or title
        existing_page = if page_id
          Page.find :id => page_id
        else
          Page.find :space => space, :title => title
        end
        
        # take page_id and version from existing page if available
        if existing_page
          if args[:recreate_if_exists]
            # remove existing page
            existing_page.remove
          else
            # update page with page_id and version info
            self.page_id = existing_page.page_id
            self.version = existing_page.version
          end
        end
      end
      
      # reinitialize page after storing it
      initialize(client.storePage(self.to_hash))
      
      # return self
      self
    end
    
    def remove
      client.removePage(page_id)
    end
    
    def to_hash
      # record hash
      record_hash = super
      
      # always include content in hash
      record_hash["content"] ||= ""
      
      # prepend details sections before content
      record_hash["content"].insert(0, details.to_s)
      
      # result
      record_hash
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

class String
  def to_page_title
    self.gsub(Confluence::Page::INVALID_TITLE_CHARS, "").strip
  end
end