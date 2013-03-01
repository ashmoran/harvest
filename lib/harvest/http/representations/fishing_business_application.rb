module Harvest
  module HTTP
    module Representations
      class FishingBusinessApplication
        include Roar::Representer::JSON::HAL
        include Representable::Coercion

        property :fisherman_uuid, type: String # Not really!
      end
    end
  end
end
