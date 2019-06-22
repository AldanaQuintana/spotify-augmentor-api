#!/usr/bin/env ruby
require 'json'
require_relative '../domain/queue/queue_publisher'

track_id_samples_file = File.expand_path 'data/track_id_samples', File.dirname(__FILE__)
track_ids = JSON.parse(`cat #{track_id_samples_file}`)

played_tracks = 10.times.map do 
	{
		track_id: track_ids.sample,
		user_id: rand(15),
		timestamp: Time.now
	}
end

message = {
	tracks: played_tracks
}

QueuePublisher::PlayedTracks.publish({ message: message })