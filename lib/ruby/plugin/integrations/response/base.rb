module Ruby
  module Plugin
    module Integrations
      module Response
        # Base class that holds response shared among integrations
        class Base
          require 'pry-byebug'

          attr_reader :headers, :code, :original_response

          def initialize(response)
            @body = response.body
            @headers = response.headers
            @code = response.code
            @original_response = response
          end

          def body
            @body.empty? ? 'OK' : @body
          end

          def success?
            [200, 201].include?(code)
          end
        end
      end
    end
  end
end
