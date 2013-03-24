module Harvest
  module HTTP
    module Representations
      class FishermanRegistrar
        include Roar::Representer::JSON::HAL

        attr_reader :base_uri

        # Pretend to be a state_machine state machine
        property :location
        def location
          "inside_registrars_office"
        end

        def initialize(base_uri, read_model)
          @base_uri = base_uri
          @read_model = read_model
        end

        collection :"registered-fishermen", class: Fisherman, embedded: true

        define_method :"registered-fishermen" do
          @read_model.records.map { |fisherman_record| Fisherman.new(fisherman_record) }
        end

        link :self do
          base_uri + "/api/fisherman-registrar"
        end
      end
    end
  end
end
