module Ruby
  module Plugin
    module Integrations
      module RaveEdc
        require 'ruby/plugin/integrations/request/base'
        require 'ruby/plugin/integrations/rave_edc/response'
        require 'erb'
        require 'securerandom'
        # The class that actually interacts with the EDC
        class Request < Ruby::Plugin::Integrations::Request::Base
          base_uri ENV['RAVE_BASE_URL']
          basic_auth(ENV['RAVE_USER'], ENV['RAVE_PASSWORD'])
          headers 'Content-Type' => 'text/xml', 'accept-encoding' => 'none'

          STUDY_OID = ENV['RAVE_STUDY_OID']

          def initialize(request)
            super
            @response_class = Ruby::Plugin::Integrations::RaveEdc::Response
            build_request_context if verb == 'post'
          end

          private

          # It's assumed the form is already setup on the rave
          def submit_simple_form
            self
              .class
              .send(verb, '/webservice.aspx?PostODMClinicalData', body: data)
          end

          def build_request_context
            location_oid = params.fetch('site_id')
            study_event_oid = params.fetch('study_event')
            subject_id = params.fetch('subject_id')
            study_oid = STUDY_OID
            file_oid = SecureRandom.uuid
            item_group_oid = params.fetch('form_id')
            form_oid = item_group_oid
            form_items = data['form_items'].map{ |key, value| { 'oid' => key, 'value' => value } }
            subject_data_transaction_type = params.fetch('subject_data_transaction_type', 'Update')
            creation_time = Time.now.utc.strftime('%FT%T')
            template = ERB.new(
              File.read(
                File.expand_path(File.join('lib', 'ruby', 'plugin', 'utils', 'rave_xml_templates', 'postdata.xml.erb'))
              )
            )
            @data = template.result(binding)
          end

          def subject_data
            subject_id = params['subject_id']
            request_url = "/studies/#{STUDY_OID}/subjects/#{subject_id}/datasets/regular".gsub(' ', '%20')
            self.class.send(verb,request_url)
          end

          def subjects
            self.class.send(
              verb,
              "/studies/#{STUDY_OID}/Subjects".gsub(' ', '%20')
            )
          end
        end
      end
    end
  end
end
