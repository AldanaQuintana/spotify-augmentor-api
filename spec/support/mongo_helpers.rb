module MongoHelpers
	def tracks_played_collection
		MongoClient.current[:tracks_played]
	end

	def saved_track_entry
		saved_track_entries.first
	end

	def saved_track_entries
		tracks_played_collection.find({})
	end

	def insert_track(track_id, user_id, timestamp)
		tracks_played_collection.insert_one(
			{ id: track_id, user_id: user_id, timestamp: timestamp }
		)
	end
end