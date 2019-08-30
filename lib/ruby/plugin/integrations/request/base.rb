module Ruby
  module Plugin
    module Integrations
      module Request
        # Base class that provides functionality shared among integrations
        class Base
          require 'pry-byebug'
          require 'ruby/plugin'
          require 'httparty'
          require 'ruby/plugin/integrations/response/base'

          include HTTParty

          attr_reader :action, :data, :verb, :message_properties, :params

          def self.call(*args)
            new(*args).call
          end

          # @param request [Hash] everything needed to assemble the request including the original message
          # TODO remove request action in favor of params
          def initialize(request)
            @action = request[:action]
            @verb = request[:verb].downcase
            @data = apply_mappings(request[:body])
            @params = request[:params]
            @message_properties = request[:message_properties]
            @response_class = Ruby::Plugin::Integrations::Response::Base
          end

          def call
            response = @response_class.new(send(action))
            with_transmission_log(request_body: data&.to_json, response: response) do
              if response.success?
                return response.body
              elsif response.code == 400
                raise Ruby::Plugin::RequestError.new(
                  'Bad or malformed request',
                  'BAD_REQUEST'
                )
              elsif response.code == 404
                raise Ruby::Plugin::RequestError.new(
                  'Resource not found',
                  'NOT_FOUND'
                )
              else
                raise "http_status=#{response.code} body=#{response.body}"
              end
            end
          end

          # TODO push call upwards and do request level logging here
          # using sneakers logger

          private

          def with_transmission_log(request_body:, response:)
            puts "Executing action: #{action} with body: #{request_body}"
            puts %{
              Done with action: "#{action}", sent response to Toolkit:
              #{response.body}
              Original response is #{response.original_response}
            }
            yield
          end

          # TODO skip if there is not mappings to be applied
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
end
