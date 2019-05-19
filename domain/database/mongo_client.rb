require 'mongo'

class MongoClient
  class << self
    def current
      @@client ||= self.initialize_client
    end

    def initialize_client(env = ENV['RACK_ENV'])
      config = "mongodb://#{ENV['MONGODB_HOST']}"
      Mongo::Client.new(config, :database => 'spotify_augmentor_api')
    end
  end
end