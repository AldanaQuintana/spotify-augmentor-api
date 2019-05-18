$LOAD_PATH.concat([
  '/domain',
  '/plugins',
  '/routes'
].map { |path| File.dirname(__FILE__) + path })

require 'json'
require 'logger'

require "cuba"
require "cuba/safe"

require 'json_params'
require 'logging'

require 'spotify_augmentor'

require 'base_app_api'

Cuba.use Rack::Session::Cookie, secret: ENV['SECRET'] || SecureRandom.hex

Cuba.plugin Cuba::Safe
Cuba.plugin Cuba::JSONParams
Cuba.plugin Cuba::Logging

BaseAppAPI.logger = Cuba.logger

Cuba.define do
  on default do
    begin
      logger.info("#{req.request_method} #{req.path} #{params}")
      run  Routes::SpotifyAugmentor
    rescue BaseAppAPI::Error => e
      res.status = 422
      res.write({ message: e.message}.to_json )
    rescue StandardError => e
      logger.error(e)
      res.status = 500
    end
  end
end