ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'pry'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }
require File.join(File.dirname(File.expand_path(__FILE__)), '../app.rb')

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RequestHelpers
  config.color = true

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.after(:each) do
    # Clean your database here
  end

  config.before do
    test_logger = Logger.new('./log/test.log')
    test_logger.level = Logger::INFO

    app.settings[:logger] = test_logger

    BaseAppAPI.logger = test_logger
  end
end

def app
  Cuba
end