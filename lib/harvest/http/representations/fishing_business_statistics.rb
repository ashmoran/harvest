module Harvest
  module HTTP
    module Representations
      class FishingBusinessStatistics
        include Roar::Representer::JSON::HAL

        # Duplicated with the read model
        property :fishing_ground_uuid,   type: String # Not really!
        property :fishing_business_uuid, type: String # Not really!
        property :lifetime_fish_caught,  type: Integer
        property :lifetime_profit,       type: String # Not really!
        attr_accessor :fishing_ground_uuid, :fishing_business_uuid, :lifetime_fish_caught, :lifetime_profit

        # The default ROAR #from_hash doesn't symbolize keys
        # Also no base_uri here either
        def initialize(attributes = (blank=true; nil))
          if !blank
            attributes.symbolize_keys.each do |property, attribute|
              self.send(:"#{property}=", attribute)
            end
          end
        end
      end
    end
  end
end
