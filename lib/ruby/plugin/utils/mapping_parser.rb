module Ruby
  module Plugin
    module Utils
      class MappingParser
        require 'json'
        require 'open-uri'

        def self.parse
          mapping_url = ENV['INTEGRATION_MAPPING_URL']
          return {} if mapping_url.nil? || mapping_url.strip.empty?
          JSON.load(open(mapping_url))
        end
      end
    end
  end
end
