require 'sneakers'
require 'json'
require 'as-duration'
require_relative '../database/mongo_client'
require_relative 'message_delayer'

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
  end

  class TracksPlayed < Base
    from_queue :events, exchange: "tracks", exchange_type: :topic, routing_key: ["tracks.played"], ack: true

    def _work(deserialized)
      tracks = deserialized["tracks"]

      ops = tracks.map do |entry|
        {
          update_one: {
            filter: { id: entry["id"], user_id: entry["user_id"] },
            update: { id: entry["id"], user_id: entry["user_id"], timestamp: Time.parse(entry["timestamp"])},
            upsert: true
          }
        }
      end


      MongoClient.current[:tracks_played].bulk_write(ops)
    end
  end

  class Top10Worker < Base
    from_queue :batch_process, durable: true

    def _work(deserialized)
      period = deserialized["period"]
      from = Time.parse(period["from"])
      to = Time.parse(period["to"])


      played_on_period = MongoClient.current[:tracks_played].aggregate([
        {
          "$match" => { timestamp: { "$gt" => from, "$lt" => to } }
        },
        {
          "$group" => { _id: "$id", play_count: { "$sum" => 1 } }
        },
        {
          "$sort" => { play_count: -1 }
        },
        {
          "$limit" => 10
        }
      ])

      if (played_on_period.count > 0)
        MongoClient.current[:top_10].insert_one({
          from: from,
          to: to,
          tracks: played_on_period.map do |entry|
            { id: entry["_id"], play_count: entry["play_count"] }
          end
        })

        MongoClient.current[:tracks_played].delete_many(
          {
            timestamp: { "$gt" => from, "$lt" => to }
          }
        )
      end

      # This defines the level of 'real-timeness' of the api
      delay_in_ms = 10.minutes.to_i * 1000

      MessageDelayer.deliver_async({message: {
        top_10_since: to + 1.second
      }, delay: delay_in_ms })
    end
  end
end
