module Ruby
  module Plugin
    module Utils
      # Handling parsing of query params
      class QueryParamParser
        require 'cgi'

        def self.action(msg)
          url = msg.dig('sourceBean', 'requestPath')
          return if url.nil? || url.strip.empty?

          CGI::parse(URI.parse(url).query).fetch('action', []).first
        end
      end
    end
  end
end
