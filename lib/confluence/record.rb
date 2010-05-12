module Confluence
  # Base class for working with Confluence records.
  #
  class Record
    class << self
      # The client used for Confluence API calls.
      #
      def client
        raise "Confluence client is unavailable. Did you forget to use Confluence::Session.new?" unless @@client
        @@client
      end

      # Sets the client.
      #
      def client=(value)
        @@client = value
      end
      
      # Defines an attr_accessor for a Record attribute.
      #
      def record_attr_accessor(*args)
        attributes = {}
        
        # iterate through each argument
        args.each do |arg|
          attributes = case arg
          when Symbol: { arg => arg }
          when Hash: arg
          else break
          end

          attributes.each_pair do |key, name|
            class_eval %Q{
              def #{name}
                self[:#{key}]
              end
            
              def #{name}=(value)
                self[:#{key}] = value
              end
            }
          end
        end
      end
    end

    # Returns the the Confluence API client.
    #
    def client
      Record.client
    end

    # Initializes a new record.
    #
    # ==== Parameters
    # hash<Hash>:: A hash containing the attributes and its values. Keys can be Strings or Symbols.
    def initialize(hash = {})
      @attributes = {}

      # iterate through each key/value pair and set attribute keyed by symbol
      hash.each_pair do |key, value|
        self[key.to_sym] = value
      end
    end
    
    def [](attr)
      @attributes[attr]
    end
    
    def []=(attr, value)
      @attributes[attr] = value
    end

    # Returns the id of the record.
    #
    def record_id
      self[:id]
    end
    
    # Retrieves the labels of the record.
    #
    def labels
      @labels ||= client.getLabelsById(record_id).collect {|label| label["name"]}
    end
    
    # Sets the labels of the record.
    #
    def labels=(value)
      removed_labels = labels - value
      added_labels = value - labels
      
      client.removeLabelByName(removed_labels.join(" "), record_id) unless removed_labels.empty?
      client.addLabelByName(added_labels.join(" "), record_id) unless added_labels.empty?
      
      @labels = value
    end
    
    def to_hash
      hash = Hash.new
      @attributes.each { |key, value| hash[key.to_s] = value }
      hash
    end
  end
end