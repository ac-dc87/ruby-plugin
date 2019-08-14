module Ruby
  module Plugin
    # Handling configuration validation
    # building configuration object from environment
    class Config
      def self.validate_configuration
        amqp_url = ENV['AMQP_URL']
        raise 'Environment variable AMQP_URL needs to be set' unless amqp_url
        consumer_threads = ENV['CONSUMER_THREADS'] ? ENV['CONSUMER_THREADS'].to_i : 10
        consumer_workers = ENV['CONSUMER_WORKERS'] ? ENV['CONSUMER_WORKERS'].to_i : 3
        log_output = ENV['LOG_FILE'] || STDOUT
        integration = ENV['INTEGRATION']
        raise %{
          Environment variable INTEGRATION needs to be set
          Possible values are #{Ruby::Plugin::HANDLERS.keys}
        } unless integration
        {
          amqp_url: amqp_url,
          consumer_threads: consumer_threads,
          consumer_workers: consumer_workers,
          log_output: log_output,
          integration: integration,
          error_queue: 'Toolkit.Error'
        }
      end
    end
  end
end
