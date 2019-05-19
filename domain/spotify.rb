require "net/http"
require "base64"

class SpotifyAuthException < Exception
	def initialize(res)
		super(res)
	end
end

class Spotify
	@@token = ''
	
	class << self
		def get_track
			get '/v1/tracks/2TpxZ7JUBn3uw46aR7qd6V'
		end

		# Available http methods against Spotify Api

		def get(path)
			with_auth_refresh do
				uri = URI("https://api.spotify.com#{path}")
				req = Net::HTTP::Get.new uri, { 'Authorization' => "Bearer #{@@token}" }
				Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
					http.request(req)
				end
			end
		end

		# Authentication

		def with_auth_refresh(&block)
			res = instance_eval &block

			return res unless res.is_a?(Net::HTTPBadRequest) || res.is_a?(Net::HTTPUnauthorized)
			
			authenticate!
			instance_eval &block
		end

		def authenticate!
			uri = URI('https://accounts.spotify.com/api/token')

			req = Net::HTTP::Post.new(uri)
			req.basic_auth(ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'])
			req.set_form_data('grant_type' => 'client_credentials')

			res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
				http.request(req)
			end

			if res.is_a? Net::HTTPSuccess
				@@token = JSON.parse(res.body)["access_token"]
			else
				raise SpotifyAuthException.new(res)
			end
		end
	end
end