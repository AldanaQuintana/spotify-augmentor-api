class Cuba
  module Logging
    def self.setup(app)
      app.settings[:logger] = Logger.new(STDOUT)
      app.settings[:logger].level = Logger::INFO
    end

    def logger
      settings[:logger]
    end

    module ClassMethods
      def logger
        settings[:logger]
      end
    end
  end
end