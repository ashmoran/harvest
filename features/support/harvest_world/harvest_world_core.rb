require 'facets/hash/autonew'

module HarvestWorld
  module Core
    def client
      @client ||= new_client
    end

    # This is the "someone" referred to the Cucumber specs
    def someone
      @someone ||= new_client
    end

    def fisherman_clients
      @fisherman_clients ||= { }
    end

    def known_aggregate_root_uuids
      @known_aggregate_root_uuids ||= Hash.autonew
    end
  end
end