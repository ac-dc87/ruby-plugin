module Ruby
  module Plugin
    module Integrations
      module PrismEdc
        require 'ruby/plugin/integrations/request/base'
        # The class that actually interacts with the EDC
        class Request < Ruby::Plugin::Integrations::Request::Base
          require 'sneakers'

          base_uri ENV['PRISM_TOOLKIT_URL']
          logger ::Sneakers.logger, :info
          headers 'Content-Type' => 'application/json'

          private

          def enroll_subject
            self
              .class
              .send(verb, '/rest/v1/custom/nextrials.prism/enroll', body: data.to_json)
          end

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
end
