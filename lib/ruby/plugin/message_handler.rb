module Ruby
  module Plugin
    # Handles incoming messages and hands them off to appropriate integration
    class MessageHandler
      require 'ruby/plugin'
      # TODO maybe map errors to the particular http status
      EXPECTED_ERRORS = [
        EOFError,
        Errno::ECONNRESET,
        Errno::EINVAL,
        Net::HTTPBadResponse,
        Net::HTTPHeaderSyntaxError,
        Net::ProtocolError,
        Timeout::Error,
        Ruby::Plugin::Error
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
        msg = JSON.parse(message)
        if msg.dig('sourceBean', 'requestMethod') != 'POST'
          raise Ruby::Plugin::Error.new(
            'All requests have to be use verb POST'
          )
        end
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
        inner_body = JSON.parse(msg['message'])
        {
          original_payload: msg,
          method: inner_body['method'],
          body: inner_body['body']
        }
      end
    end
  end
end
