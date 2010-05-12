module Confluence
  # Wraps a Confluence::Client and manages the lifetime of a session.
  #
  class Session
    attr_reader :client
    
    # Initializes a new session with the given arguments and sets it for other classes like Confluence::Page.
    #
    # If a block is given to initialize, initialize yields with the Confluence::Client and automatically logs out of the session afterwards. 
    # Otherwise Session#destroy should be called after finished.
    #
    # ==== Parameters
    # arguments<Hash>:: Described below.
    #
    # ==== Arguments
    # :url      - The url of the Confluence instance.
    # :username - The username.
    # :password - The password.
    #
    def initialize(arguments = {})
      raise ArgumentError, "Required argument 'url' is missing." unless arguments.key? :url
      
      @client = Confluence::Client.new(arguments)
      
      unless @client.has_token?
        raise ArgumentError, "Required argument 'username' is missing." unless arguments.key? :username
        raise ArgumentError, "Required argument 'password' is missing." unless arguments.key? :password
        
        @client.login(arguments[:username], arguments[:password])
      end

      # set client for records
      Confluence::Record.client = @client

      # yield if block was given and destroy afterwards
      if block_given?
        yield @client

        self.destroy
      end
    end
    
    # Returns the current session token.
    #
    def token
      client.token if client
    end
    
    # Destroys the session by logging out and resets other classes like Confluence::Page.
    #
    def destroy
      # invalidate the token
      client.logout
      
      # client is not valid anymore
      @client = nil
      
      # reset client for records
      Confluence::Record.client = nil
    end
  end
end