module Harvest
  module HTTP
    module Representations
      class FishermanRegistrar
        include Roar::Representer::JSON::HAL

        def initialize(read_model)
          @read_model = read_model
        end

        collection :"registered-fishermen", class: Fisherman, embedded: true

        define_method :"registered-fishermen" do
          @read_model.records.map { |fisherman_record| Fisherman.new(fisherman_record) }
        end
      end
    end
  end
end
