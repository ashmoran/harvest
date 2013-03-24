module HarvestWorld
  module HTTP
    def client
      require 'harvest/clients/harvest_http_client'
      @client ||= Harvest::Clients::HarvestHTTPClient.new("http://localhost:3000/api").tap do |client|
        client.start
      end
    end

    def app
      @app ||= ($harvest_app ||= Harvest::App.new)
    end

    def run_app
      require 'harvest/http/server'
      $server = Harvest::HTTP::Server::HarvestHTTPServer.new(harvest_app: app, port: 3000)
      $server.start
    end

    def reset_app
      $harvest_app.reset
    end

    def known_aggregate_root_uuids
      @known_aggregate_root_uuids ||= Hash.autonew
    end

    def poseidon
      client.poseidon
    end

    def read_models
      client.read_models
    end
  end
end