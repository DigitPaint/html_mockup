module HtmlMockup
  module Rack
    # Listens to the "sleep" parameter and sleeps the amount of seconds specified by the parameter. There is however a maximum of 5 seconds.
    class Sleep
  
      def initialize(app)
        @app = app
      end
  
      def call(env)
        r = Rack::Request.new(env)
        if r.params["sleep"]
          sleeptime = [r.params["sleep"].to_i, 5].min
          sleep sleeptime
        end
        @app.call(env)
      end
  
    end
  end
end