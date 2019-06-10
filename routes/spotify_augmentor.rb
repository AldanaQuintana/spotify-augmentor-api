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

			result = top_10.find({
	           from: { "$lt" => datetime },
	           to: { "$gte" => datetime }
	        }).first || top_10.find({}, { :sort => { 'to' =>  -1 } }).first

			res.status = 200
			res.write({top_10: result}.to_json)
		end
	end
end