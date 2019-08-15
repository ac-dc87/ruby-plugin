module Ruby
  module Plugin
    module Integration
      # The class that actually interacts with the EDC
      class PrismEdc
        require 'pry-byebug'
        require 'ruby/plugin'
        require 'httparty'

        include HTTParty
        base_uri ENV['PRISM_TOOLKIT_URL']
        headers 'Content-Type' => 'application/json'

        attr_reader :request_method, :data

        def self.call(*args)
          new(*args).call
        end

        # @param request_method [Hash] Verb and action name
        # @param request_body [Hash] Request body
        def initialize(request)
          @request_method = request[:method]
          @data = request[:body]
        end

        def call
          response = send(request_method['action'], data)
          if [200, 201].include? response.code
            return response.body.empty? ? 'OK' : response.body
          else
            raise "http_status=#{response.code} body=#{response.body}"
          end
        end

        private

        def send_form_event(body)
          self.class.post('/rest/v1/custom/prism/add', body: body.to_json) # could use request_method['name']
        end

        def edit_event(body)
          self.class.post('/rest/v1/custom/prism/edit', body: body.to_json) # could use request_method['name']
        end
      end
    end
  end
end
