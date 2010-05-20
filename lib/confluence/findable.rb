module Confluence
  module Findable
    # Finds records by the given criteria.
    #
    # ==== Parameters
    # args<Hash>:: The search arguments.
    def find(args)
      begin
        case args
        when :all: begin
          raise "Cannot find all #{self.class.name.downcase}s, find by criteria instead." unless respond_to? :find_all
          find_all
        end
        when Hash: find_criteria(args)
        end
      rescue Confluence::Error
      end
    end
  end
end