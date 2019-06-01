require_relative 'queue_publisher'

class MessageDelayer < QueuePublisher::Base
  def self.deliver_async(options)
    self.publish(options)
  end

  def routing_key
    "batch_process"
  end

  def create_exchange
    channel.default_exchange
  end

  def publish(options)
    if !options[:delay].nil?
      message = options[:message]

      from = Time.now
      delay_in_ms = options[:delay].to_i
      key = "batch_process.queued_at_#{from}.process_at_#{from + delay_in_ms}"

      queue = channel.queue(key, :arguments => {
        "x-dead-letter-exchange" => "",
        'x-dead-letter-routing-key' => "batch_process",
        "x-message-ttl" => delay_in_ms,
        "x-expires" => delay_in_ms + 100
        })

      exchange = create_exchange
      exchange.publish({message: message}.to_json, :routing_key => key)

      close_connection
    else
      super
    end
  end
end