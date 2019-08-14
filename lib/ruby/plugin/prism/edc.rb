module Ruby
  module Plugin
    module Prism
      # The class that actually interacts with the EDC
      class Edc
        require 'pry-byebug'
        require 'ruby/plugin'
        attr_reader :message

        def self.process(*args)
          new(*args).call
        end

        # @param message [String] rabbitMQ message
        def initialize(message)
          @message = message
        end

        def call
          msg = JSON.parse(message)
          if msg.dig('sourceBean', 'requestMethod') != 'POST'
            raise Ruby::Plugin::CustomProcessingResponseException.new(
              'All requests have to be use verb POST',
              'NOT_FOUND'
            )
          end
        end
      end
    end
  end
end
