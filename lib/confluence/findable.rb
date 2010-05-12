module Confluence
  module Findable
    # Finds records by the given criteria.
    #
    # ==== Parameters
    # args<Hash>:: The search arguments.
    def find(args)
      begin
        case args
        when :all: find_all
        when Hash: find_criteria(args)
        end
      rescue Confluence::Error
      end
    end
  end
end