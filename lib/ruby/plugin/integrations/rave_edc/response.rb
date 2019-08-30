module Ruby
  module Plugin
    module Integrations
      module RaveEdc
        require 'ruby/plugin/integrations/response/base'
        # EDC specific response
        class Response < Ruby::Plugin::Integrations::Response::Base
          def body
            original_response.to_json
          end

          def success?
            if original_response.key?('Response')
              original_response.dig('Response', 'IsTransactionSuccessful') == '1'
            else
              super
            end
          end
        end
      end
    end
  end
end
