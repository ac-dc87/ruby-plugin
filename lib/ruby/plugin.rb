require 'ruby/plugin/version'
require 'ruby/plugin/integrations/prism_edc/request'
require 'ruby/plugin/integrations/rave_edc/request'

module Ruby
  module Plugin
    INTEGRATIONS = {
      'prism_edc' => {
        klass: Ruby::Plugin::Integrations::PrismEdc::Request,
        config_keys: %w[prism_toolkit_url integration_mapping_url]
      },
      'rave_edc' => {
        klass: Ruby::Plugin::Integrations::RaveEdc::Request,
        config_keys: %w[rave_base_url rave_study_oid]
      }
    }
    class Error < StandardError; end
    class RequestError < Error
      attr_reader :message, :http_status
      def initialize(message, http_status)
        @message = message
        @http_status = http_status
      end
    end
    class CustomProcessingResponseException < Error
      attr_reader :local_message, :http_status,
                  :profile, :message, :localized_message
      def initialize(message, http_status)
        @local_message = message
        @http_status = http_status
        @profile = 'Custom'
        @message = %{
          Attempted Profile: Custom
          ESOURCE Error:
          Plugin exception:
          Error processing request: #{message}
        }
        @localized_message = %{
          Attempted Profile: Custom
          ESOURCE Error:
          Plugin exception:
          Error processing request: #{message}
        }
      end

      def queue_serializable_error
        {
          localMessage: local_message,
          httpStatus: http_status,
          cause: cause,
          profile: profile,
          message: message,
          localizedMessage: localized_message,
          suppressed: []
        }
      end
    end
  end
end
