module Harvest
  module HTTP
    module Representations
      class FishingOrder
        include Roar::Representer::JSON::HAL
        include Representable::Coercion

        property :fishing_business_uuid, type: String # Not really!
        property :order, type: Integer # I think I'd prefer this to be :order_quantity
      end
    end
  end
end
