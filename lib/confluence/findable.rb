module Confluence
  module Findable
    # Finds records by the given criteria.
    #
    # ==== Parameters
    # args<Hash>:: The search arguments.
    def find(args)
      if args.has_key?(:all) && !respond_to?(:find_all)
        raise "Cannot find all #{self.class.name.downcase}s, find by criteria instead."
      end

      begin
        case args
        when :all
          find_all
        when Hash 
          find_criteria(args)
        end
      rescue Confluence::Error
      end
    end
  end
end
