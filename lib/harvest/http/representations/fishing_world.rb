module Harvest
  module HTTP
    module Representations
      class FishingWorld
        include Roar::Representer::JSON::HAL

        attr_reader :base_uri

        def initialize(base_uri, fishing_grounds_available_to_join: nil, fishing_ground_businesses: nil)
          @base_uri                           = base_uri
          @fishing_grounds_available_to_join  = fishing_grounds_available_to_join
          @fishing_ground_businesses          = fishing_ground_businesses
        end

        collection :"fishing-grounds-available-to-join", class: FishingGround, embedded: true

        define_method :"fishing-grounds-available-to-join" do
          @fishing_grounds_available_to_join.records.map { |fishing_ground_record|
            FishingGround.new(
              base_uri,
              fishing_ground_record.merge(
                fishing_ground_businesses: @fishing_ground_businesses.records_for(
                  fishing_ground_record[:uuid]
                )
              )
            )
          }
        end
      end
    end
  end
end
