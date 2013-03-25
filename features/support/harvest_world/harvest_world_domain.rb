require 'facets/hash/autonew'

module HarvestWorld
  module Domain
    def app
      @app ||= Harvest::App.new
    end

    def run_app
      # Nothing to do!
    end

    def reset_app
      # Nothing to do!
    end

    private

    def new_client
      require 'harvest/clients/harvest_domain_client'
      Harvest::Clients::HarvestDomainClient.new(app)
    end
  end
end

