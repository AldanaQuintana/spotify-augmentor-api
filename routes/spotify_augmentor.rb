module Routes
  class SpotifyAugmentor < Cuba
  end
end

Routes::SpotifyAugmentor.define do
	on 'ping' do
		on get do
			res.status = 200
			res.write 'pong'
		end
	end
end