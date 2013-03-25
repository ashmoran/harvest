module HarvestWorld
  module HTTP
    def app
      @app ||= ($harvest_app ||= Harvest::App.new)
    end

    def run_app
      require 'harvest/http/server'
      $server = Harvest::HTTP::Server::HarvestHTTPServer.new(harvest_app: app, port: 3000)
      $server.start
    end

    # Not sure why we can't use @app here any more - this should
    # only ever be called after run_app
    def reset_app
      app.reset
    end

    private

    def new_client
      require 'harvest/clients/harvest_http_client'
      Harvest::Clients::HarvestHTTPClient.new("http://localhost:3000/api").tap do |client|
        client.start
      end
    end
  end
end