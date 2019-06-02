require 'bunny'

module QueuePublisher
  class Base
    def self.publish(options)
      self.new.publish(options)
    end

    def self.work(options)
      self.publish(options)
    end

    def create_exchange
      channel.topic("tracks", :durable => true)
    end

    def routing_key
      raise "Should be implemented in subclass"
    end

    def publish!(options, exchange)
      exchange.publish({ message: options[:message]}.to_json, :routing_key => routing_key)
    end

    def publish(options)
      exchange = create_exchange

      publish!(options, exchange)

      close_connection
    end

    def close_connection
      connection.close

      @channel = nil
      @connection = nil
    end

    def channel
      @channel ||= connection.create_channel
    end

    def connection
      @connection ||= Bunny.new(configuration).tap do |con|
        con.start
      end
    end

    def configuration
      ENV['AMQP_URI']
    end
  end

  class PlayedTracks < Base
    def routing_key
      "tracks.played"
    end
  end
end