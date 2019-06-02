require_relative 'queue_publisher'
require 'as-duration'

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
      message = message_from(options)

      from = Time.now
      delay_in_ms = options[:delay].to_i
      key = "send.later.queued_at_#{from}.process_at_#{(from + (delay_in_ms / 1000).seconds)}"

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

  def message_from(options)
  	if(!options[:message].nil? && !options[:message][:top_10_since].nil?)
  		from = options[:message][:top_10_since]
  		to = from + options[:delay].to_i

  		{
  			period: {
  				from: from,
  				to: to
  			}
  		}
  	end
  end
end