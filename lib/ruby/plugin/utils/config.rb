module Ruby
  module Plugin
    module Utils
      # Handling configuration validation
      # building configuration object from environment
      class Config
        require 'ruby/plugin/utils/mapping_parser'
        require 'ruby/plugin/worker'

        def self.validate_configuration
          amqp_url = ENV['AMQP_URL']
          raise 'Environment variable AMQP_URL needs to be set' if amqp_url.nil? || amqp_url.strip.empty?
          consumer_threads = ENV['CONSUMER_THREADS'] ? ENV['CONSUMER_THREADS'].to_i : 10
          consumer_workers = ENV['CONSUMER_WORKERS'] ? ENV['CONSUMER_WORKERS'].to_i : 3
          log_output = ENV['LOG_FILE'] || STDOUT
          integration = validate_integration_configuration
          {
            amqp_url: amqp_url,
            consumer_threads: consumer_threads,
            consumer_workers: consumer_workers,
            log_output: log_output,
            integration: integration,
            error_queue: 'Toolkit.Error',
            mapping: MappingParser.parse
          }
        end

        def self.validate_integration_configuration
          integration = Ruby::Plugin::INTEGRATIONS.fetch(ENV['INTEGRATION'], nil)
          integration = integration.strip if integration.respond_to?(:strip)
          raise %(
            Environment variable INTEGRATION needs to be set
            Possible values are #{Ruby::Plugin::INTEGRATIONS.keys}
          ) if integration.nil? || integration.empty?

          validate_integration_configuration_keys(integration)

          queue_name = ENV['INTEGRATION_QUEUE_NAME']
          raise 'Environment variable INTEGRATION_QUEUE_NAME needs to be set' if queue_name.nil? || queue_name.strip.empty?

          Ruby::Plugin::Worker.from_queue(queue_name)

          return integration
        end

        def self.validate_integration_configuration_keys(integration)
          return unless integration[:config_keys]
          missing_config_keys = integration[:config_keys].reject { |key| ENV.key?(key.upcase) }.map(&:upcase)

          raise %{
            Please set the following environment variables:
            #{missing_config_keys.join(', ')}
          } unless missing_config_keys.empty?

          blank_config_keys = integration[:config_keys].select{ |key| ENV[key.upcase].strip.empty? }.map(&:upcase)

          raise %{
            Following environment variables cannot be empty/blank:
            #{blank_config_keys.join(', ')}
          } unless blank_config_keys.empty?
        end
      end
    end
  end
end
