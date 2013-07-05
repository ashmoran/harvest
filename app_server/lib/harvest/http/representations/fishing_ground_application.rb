module Harvest
  module HTTP
    module Representations
      class FishingGroundApplication
        include Roar::Representer::JSON::HAL
        include Representable::Coercion

        property :name,                 type: String
        property :starting_population,  type: Integer
        property :carrying_capacity,    type: Integer
        property :starting_year,        type: Integer
        property :lifetime,             type: Integer
        property :order_fulfilment,     type: Symbol
      end
    end
  end
end
