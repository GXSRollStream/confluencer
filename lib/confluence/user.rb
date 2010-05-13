module Confluence
  class User < Record
    extend Findable
    
    record_attr_accessor :name, :fullname, :email, :url

    private
    
    def self.find_all
      client.getActiveUsers(true).collect { |name| User.find :name => name }
    end
    
    def self.find_criteria(args)
      if args.key? :name
        User.new(client.getUser(args[:name]))
      end
    end
  end
end