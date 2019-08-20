module Ruby
  module Plugin
    module Integrations
      # Base class that provides functionality shared among integrations
      class Base
        require 'pry-byebug'
        require 'ruby/plugin'
        require 'httparty'

        include HTTParty

        attr_reader :action, :data, :verb, :message_properties

        # @param request [Hash] everything needed to assemble the request including the original message
        def initialize(request)
          @action = request[:action]
          @verb = request[:verb].downcase
          @data = apply_mappings(request[:body])
          @message_properties = request[:message_properties]
        end

        # TODO push call upwards and do request level logging here

        private

        def apply_mappings(body)
          {}.tap do |hash|
            mapping_data = $config.dig(:mapping, 'data')
            body.each do |key, value|
              hash[mapping_data.fetch(key, key)] = map_value(value)
            end
          end
        end

        def map_value(thing)
          return apply_mappings(thing) if thing.is_a? Hash
          thing
        end
      end
    end
  end
end
