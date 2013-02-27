module Harvest
  module HTTP
    module Representations
      class FishingWorld
        include Roar::Representer::JSON::HAL

        def initialize(read_model)
          @read_model = read_model
        end

        collection :"fishing-grounds-available-to-join", class: FishingGround, embedded: true

        define_method :"fishing-grounds-available-to-join" do
          @read_model.records.map { |fishing_ground_record| FishingGround.new(fishing_ground_record) }
        end
      end
    end
  end
end
