module Ruby
  module Plugin
    module Utils
      # Handles incoming messages and hands them off to appropriate integration
      class MessageHandler
        require 'ruby/plugin'
        require 'ruby/plugin/utils/query_param_parser'
        # TODO maybe map errors to the particular http status
        EXPECTED_ERRORS = [
          EOFError,
          Errno::ECONNRESET,
          Errno::EINVAL,
          Net::HTTPBadResponse,
          Net::HTTPHeaderSyntaxError,
          Net::ProtocolError,
          Timeout::Error,
          Ruby::Plugin::Error,
          JSON::ParserError
        ].freeze

        attr_reader :message

        def self.handle(*args)
          new(*args).handle
        end

        # @param message [String] rabbitMQ message
        def initialize(message)
          @message = message
        end

        def handle
          $config.dig(:integration, :klass).call(request)
        rescue *EXPECTED_ERRORS => err
          raise Ruby::Plugin::CustomProcessingResponseException.new(
            err.message,
            'UNPROCESSABLE_ENTITY'
          )
        rescue StandardError => err
          raise Ruby::Plugin::CustomProcessingResponseException.new(
            err.message,
            'INTERNAL_SERVER_ERROR'
          )
        end

        private

        def request
          msg = JSON.parse(message)
          {
            original_payload: msg,
            action: QueryParamParser.action(msg),
            verb: msg.dig('sourceBean', 'requestMethod'),
            body: JSON.parse(msg['message'])
          }
        end
      end
    end
  end
end
