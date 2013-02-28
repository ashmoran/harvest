module Harvest
  module HTTP
    module Representations
      class FishingWorld
        include Roar::Representer::JSON::HAL

        attr_reader :base_uri

        def initialize(base_uri, read_model)
          @base_uri = base_uri
          @read_model = read_model
        end

        collection :"fishing-grounds-available-to-join", class: FishingGround, embedded: true

        define_method :"fishing-grounds-available-to-join" do
          @read_model.records.map { |fishing_ground_record|
            FishingGround.new(base_uri, fishing_ground_record)
          }
        end
      end
    end
  end
end
