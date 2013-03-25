module Harvest
  module HTTP
    module Representations
      # I accidentally gutted this after exposing the fishing grounds available to join
      # in the :inside_registrars_office state of the domain client
      class FishingWorld
        include Roar::Representer::JSON::HAL

        attr_reader :base_uri

        def initialize(base_uri, fishing_grounds_available_to_join: nil, fishing_ground_businesses: nil)
          @base_uri                           = base_uri
          @fishing_grounds_available_to_join  = fishing_grounds_available_to_join
          @fishing_ground_businesses          = fishing_ground_businesses
        end
      end
    end
  end
end
