module Harvest
  module HTTP
    module Representations
      class FishingGroundBusinessStatistics
        include Roar::Representer::JSON::HAL
        # include Representable::Coercion

        attr_writer :fishing_business_statistics

        collection :"fishing-business-statistics",
          class: FishingBusinessStatistics,
          embedded: true

        define_method :"fishing-business-statistics" do
          @fishing_business_statistics.map { |statistics|
            FishingBusinessStatistics.new(statistics)
          }
        end

        # The default ROAR #from_hash doesn't symbolize keys
        # No base_uri here, but we may need it in a future refactoring
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
