module Ruby
  module Plugin
    class Worker
      require 'sneakers'
      require 'pry-byebug'
      require 'json'
      require 'ruby/plugin/utils/message_handler'

      include Sneakers::Worker

      def work_with_params(msg, headers, props)
        logger.info "Processing message: #{msg} with headers: #{headers} and properties #{props}"
        begin
          routing_key = props[:reply_to]
          headers = {
            amqp_correlationId: props[:message_id]
          }
          response_object = Ruby::Plugin::Utils::MessageHandler.handle(msg)
        rescue Ruby::Plugin::CustomProcessingResponseException => err
          routing_key = $config[:error_queue]
          response_object = err.queue_serializable_error
          headers['__TypeId__'] = 'com.prahs.esource.exception.process.CustomProcessingResponseException'
        ensure
          publish(
            response_object.to_json,
            routing_key: routing_key,
            content_type: props[:content_type],
            content_encoding: props[:content_encoding],
            headers: headers
          )
        end
        ack!
      end
    end
  end
end
