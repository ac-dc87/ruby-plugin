module Ruby
  module Plugin
    module Utils
      # Handling parsing of query params
      class QueryParamParser
        require 'cgi'

        def self.params(msg)
          url = msg.dig('sourceBean', 'requestPath')
          return if url.nil? || url.strip.empty?

          CGI::parse(URI.parse(url).query).map do |k, v|
            { k => v.first }
          end.reduce(&:merge)
        end
      end
    end
  end
end
