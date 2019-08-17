module Ruby
  module Plugin
    module Utils
      class MappingParser
        require 'json'
        require 'open-uri'

        def self.parse
          JSON.load(open(ENV['INTEGRATION_MAPPING_URL']))
        end
      end
    end
  end
end
