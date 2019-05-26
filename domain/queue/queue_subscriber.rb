require 'sneakers'
require 'json'

module QueueSubscriber
  class Base
    include Sneakers::Worker

    def _work(routing_key, deserialized)
      raise 'Should be implemented in subclass'
    end

    def work(msg)
      begin
        deserialized = JSON.parse(msg)
        _work(deserialized["message"])

        ack!
      rescue Timeout::Error => e
        requeue!
      rescue EOFError => e
        requeue!
      rescue StandardError => e
        puts "ERROR #{e} - #{msg}"

        reject!
      end
    end

    def parse_routing_key(key)
      regexp_convention = /(.+)\.(.+)/
      match_data = regexp_convention.match(key)

      match_data.nil? ? key : match_data[2]
    end
  end

  class TracksPlayed < Base
    from_queue :events, exchange: "tracks", exchange_type: :topic, routing_key: ["tracks.played"], ack: true
    # TODO: Add a TTL index

    def _work(deserialized)
      tracks = deserialized["tracks"]

      ops = tracks.map do |entry|
        {
          update_one: {
            filter: { id: entry["id"], user_id: entry["user_id"] },
            update: entry,
            upsert: true
          }
        }
      end


      MongoClient.current[:tracks_played].bulk_write(ops)
    end
  end
end
