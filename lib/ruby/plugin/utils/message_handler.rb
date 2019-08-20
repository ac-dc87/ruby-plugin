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

        attr_reader :message, :properties

        def self.handle(*args)
          new(*args).handle
        end

        # @param message Json [String] rabbitMQ message. Toolkit headers are a part of this
        # @param properties [Hash] rabbitMQ message properties
        def initialize(message, properties)
          @message = message
          @properties = properties
        end

        def handle
          $config.dig(:integration, :klass).call(request)
        rescue *EXPECTED_ERRORS => err
          raise Ruby::Plugin::CustomProcessingResponseException.new(
            err.message,
            'UNPROCESSABLE_ENTITY'
          )
        rescue Ruby::Plugin::RequestError => err
          raise Ruby::Plugin::CustomProcessingResponseException.new(
            err.message,
            err.http_status
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
          request_method = msg.dig('sourceBean', 'requestMethod')
          body = request_method == 'GET' ? {} : JSON.parse(msg['message'])
          {
            message_properties: properties,
            action: QueryParamParser.action(msg),
            verb: request_method,
            body: body
          }
        end
      end
    end
  end
end
