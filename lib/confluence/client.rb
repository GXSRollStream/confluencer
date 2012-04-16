require 'xmlrpc/client'

# Module containing Confluence-related classes.
module Confluence
  # Originally confluence4r, available at: http://confluence.atlassian.com/display/DISC/Confluence4r

  # A useful helper for running Confluence XML-RPC from Ruby. Takes care of
  # adding the token to each method call (so you can call server.getSpaces()
  # instead of server.getSpaces(token)).
  #
  # Usage:
  #
  # client = Confluence::Client.new(:url => "http://confluence.atlassian.com")
  # client.login("user", "password")
  # p client.getSpaces
  #
  class Client
    PREFIX = "confluence2"
    XMLRPC_SUFFIX = "/rpc/xmlrpc"
    
    attr_reader :url, :username, :token

    # Initializes a new client with the given arguments.
    #
    # ==== Parameters
    # arguments<Hash>:: Described below.
    #
    # ==== Arguments
    # :url    - The url of the Confluence instance. The trailing '/rpc/xmlrpc' path is optional.
    # :token  - An existing session token to reuse.
    #
		def initialize(arguments = {})
		  @url = arguments[:url]
			@token = arguments[:token]
			
      Log4r::MDC.put('token', @token || 'nil')
			log.info "initialized client (:url => #{@url}, :token => #{@token || 'nil'})"
		end

	  # Returns true, if the client has a session token.
	  #
		def has_token?
		  !@token.nil?
	  end
	  
	  # Logs in and returns the newly acquired session token.
	  #
	  # ==== Parameters
	  # username<String>:: The username.
	  # password<String>:: The password.
	  #
		def login(username, password)
		  handle_fault do
		    if @token = proxy.login(username, password)
    			Log4r::MDC.put('token', @token)
    			log.info "logged in as '#{username}' and acquired token."

  		    @username = username
    			@password = password
        end  			
	    end
	    
	    @token
		end
		
		# Logs out and invalidates the session token.
		#
		def logout
		  handle_fault do
	      @token = nil if @token and result = proxy.logout(@token)
	      log.info "logged out"
	      Log4r::MDC.put('token', 'nil')
	      result
	    end
		end	

    # Translates every call into XMLRPC calls.
    #
		def method_missing(method_name, *args)
		  handle_fault do
		    if args.empty?
  		    log.debug "#{method_name}"
		    else
		      log.debug "#{method_name}(#{(args.collect {|a| a.inspect}).join(', ')})"
	      end
	      
	      begin
   		    result = proxy.send(method_name, *([@token] + args))
   		    log.debug(result.inspect)
   		    result
   		  rescue EOFError => e
   		    log.warn "Could not complete XMLRPC call, retrying... Error: #{e.inspect}"
   		    retry
 		    end
	    end
		end
		
		private

    # Returns the Confluence::Client logger.
		def log
		  Log4r::Logger[Confluence::Client.to_s] || Log4r::Logger.root
	  end
	  
		# Returns the Confluence XMLRPC endpoint url.
	  #
	  def xmlrpc_url
	    unless @url[-11..-1] == XMLRPC_SUFFIX
	      @url + XMLRPC_SUFFIX
      else
        @url
      end
    end
    
    # Returns the XMLRPC client proxy for the Confluence API v1.
    #
		def proxy
		  @proxy ||= XMLRPC::Client.new_from_uri(xmlrpc_url).proxy(PREFIX)
	  end
	  
	  # Yields and translates any XMLRPC::FaultExceptions raised by Confluence to Confluence::Errors.
	  #
		def handle_fault(&block)
		  begin
		    block.call
			rescue XMLRPC::FaultException => e
			  log.warn message = e.faultString.rpartition(':').last.strip
			  
        case message
		    when /Transaction rolled back/
		      raise Confluence::Error, "Could not save or update record."
	      else
  				raise Confluence::Error, message
        end
			end
		end
	end
end