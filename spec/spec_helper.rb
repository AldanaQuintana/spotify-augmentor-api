ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'pry'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }
require File.join(File.dirname(File.expand_path(__FILE__)), '../app.rb')

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RequestHelpers
  config.include MongoHelpers
  config.color = true

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.after(:each) do
    MongoClient.current.database.drop
  end

  config.before do
    test_logger = Logger.new('./log/test.log')
    test_logger.level = Logger::INFO

    app.settings[:logger] = test_logger

    Mongo::Logger.logger.level = ::Logger::FATAL
    MongoClient.initialize_client
    BaseAppAPI.logger = test_logger
  end
end

def app
  Cuba
end