require 'facets/hash/autonew'

module HarvestWorld
  module Domain
    def client
      require 'harvest/clients/harvest_domain_client'
      @client ||= Harvest::Clients::HarvestDomainClient.new(app)
    end

    def app
      @app ||= Harvest::App.new
    end

    def run_app
      # Nothing to do!
    end

    def reset_app
      # Nothing to do!
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

