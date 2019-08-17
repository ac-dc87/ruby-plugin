module Ruby
  module Plugin
    module Integrations
      require 'ruby/plugin/integrations/base'
      # The class that actually interacts with the EDC
      class PrismEdc < Base
        require 'sneakers'

        base_uri ENV['PRISM_TOOLKIT_URL']
        logger ::Sneakers.logger, :info
        headers 'Content-Type' => 'application/json'

        def self.call(*args)
          new(*args).call
        end

        def call
          response = send(action)
          if [200, 201].include? response.code
            return response.body.empty? ? 'OK' : response.body
          else
            raise "http_status=#{response.code} body=#{response.body}"
          end
        end

        private

        def send_form_event
          self
            .class
            .send(verb, '/rest/v1/custom/nextrials.prism/add', body: data.to_json)
        end

        def edit_event
          self
            .class
            .send(verb, '/rest/v1/custom/nextrials.prism/edit', body: data.to_json)
        end
      end
    end
  end
end
