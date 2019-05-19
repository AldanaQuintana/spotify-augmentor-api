require 'spec_helper'
require 'database/mongo_client'

describe MongoClient do
  let!(:client){ MongoClient }
  describe 'current' do
    it do
      expect(client.current).to be_a(Mongo::Client)
      expect(client.current.database.name).to eq("spotify_augmentor_api")
    end
  end
end