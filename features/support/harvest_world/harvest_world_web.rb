module HarvestWorld
  module Web
    def app
      @app ||= ($harvest_app ||= Harvest::App.new)
    end

    def run_app
      require 'harvest/http/server'
      $server = Harvest::HTTP::Server::HarvestHTTPServer.new(
        harvest_app:  app,
        port:         3000,
        cache_path:   File.expand_path(PROJECT_DIR + "/tmp/cache/3000")
      )
      $server.start
    end

    # Not sure why we can't use @app here any more - this should
    # only ever be called after run_app
    def reset_app
      app.reset
    end

    private

    def new_client
      require 'harvest/clients/harvest_web_client'
      Harvest::Clients::HarvestWebClient.new("http://localhost:3000/").tap do |client|
        client.start
      end
    end
  end
end