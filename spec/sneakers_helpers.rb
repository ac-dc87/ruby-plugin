module Sneakers
  module Testing
    class << self
      def all
        messages_by_queue.values.flatten
      end
      def [](queue)
        messages_by_queue[queue]
      end

      def push(message, opts)
        queue = opts[:routing_key]
        messages_by_queue[queue] << message
      end

      def messages_by_queue
        @messages_by_queue ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def clear_for(queue, klass)
        messages_by_queue[queue].clear
      end

      def clear_all
        messages_by_queue.clear
      end

    end
  end
end

# Interface to fake rabbit
module WorkerAdditions
  def publish(payload, opts)
    Sneakers::Testing.push(payload, opts)
  end
end
