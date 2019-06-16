require 'database/mongo_client'
require 'spotify'

module Routes
  class SpotifyAugmentor < Cuba
  	def requested_at
		if !req.params.nil? && !req.params["at"].nil? 
			Time.parse(req.params["at"]).utc
		else
			Time.now.utc
		end
	end
  end
end

Routes::SpotifyAugmentor.define do
	on 'ping' do
		on get do
			res.status = 200
			res.write 'pong'
		end
	end

	on 'top-10' do
		on get do
			datetime = requested_at
			
			top_10 = MongoClient.current[:top_10]

			top_10_entry = top_10.find({
	           from: { "$lt" => datetime },
	           to: { "$gte" => datetime }
	        }).first || top_10.find({}, { :sort => { 'to' =>  -1 } }).first

	        result = {}
	        result['from'] = top_10_entry['from']
	        result['to'] = top_10_entry['to']

	        result['tracks'] = top_10_entry['tracks'].map do |track_entry|
	        	track_id = track_entry['id']
	        	play_count = track_entry['play_count']

	        	track = Spotify.get_track(track_id)

	        	{
	        		'id' => track_id,
	        		'play_count' => play_count,
	        		'name' => track['name'],
	        		'artist' => track['artists'][0]['name']
	        	}
	        end

			res.status = 200
			res.write({top_10: result}.to_json)
		end
	end
end