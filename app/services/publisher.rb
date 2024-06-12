class Publisher
    DEFAULT_OPTIONS = { durable: true, auto_delete: false }.freeze

    def self.publish(queue_name:, payload:)
      channel = RabbitmqConnection.instance.channel
      exchange = channel.direct("#{queue_name}_exchange", DEFAULT_OPTIONS)
      queue = channel.queue(queue_name, DEFAULT_OPTIONS)
      queue.bind(exchange, :routing_key => queue.name) 
      exchange.publish(payload, routing_key: queue.name, persistent: true)
    end
end
