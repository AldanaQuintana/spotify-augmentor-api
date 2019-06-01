module MongoHelpers
	# Tracks played helpers
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

	# Top 10 helpers
	def top_10_collection
		MongoClient.current[:top_10]
	end

	def saved_top_10_entry
		saved_top_10_entries.first
	end

	def saved_top_10_entries
		top_10_collection.find({})
	end
end