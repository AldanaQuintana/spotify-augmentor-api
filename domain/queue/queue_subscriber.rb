require 'sneakers'
require 'json'

module QueueSubscriber
  class Base
    include Sneakers::Worker

    def work(routing_key, deserialized)
      raise 'Should be implemented in subclass'
    end

    def work_with_params(msg, delivery_info, metadata)
      begin
        routing_key = parse_routing_key(delivery_info[:routing_key])
        deserialized = JSON.parse(msg)
        work(routing_key, deserialized)

        ack!
      rescue Timeout::Error => e
        requeue!
      rescue EOFError => e
        requeue!
      rescue StandardError => e
        parameters = {
          msg: msg,
          delivery_info: delivery_info,
          metadata: metadata
        }
        puts "ERROR #{e} - #{parameters}"

        reject!
      end
    end

    def parse_routing_key(key)
      regexp_convention = /(.+)\.(.+)/
      match_data = regexp_convention.match(key)

      match_data.nil? ? key : match_data[2]
    end
  end

  class Top10 < Base
    from_queue :events, exchange: "tracks", exchange_type: :topic, routing_key: ["tracks.played"], ack: true

    def work(routing_key, deserialized)
      tracks = deserialized["tracks"]

      puts tracks
      # TODO: procesar los tracks 
    end
  end
end
