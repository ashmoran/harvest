require_relative 'fishing_ground' # Unfortunate dependency

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

        def initialize(
              base_uri,
              fisherman_read_model: nil,
              fishing_ground_read_model: nil,
              fishing_ground_businesses_read_model: nil
            )
          @base_uri                             = base_uri
          @fisherman_read_model                 = fisherman_read_model
          @fishing_ground_read_model            = fishing_ground_read_model
          @fishing_ground_businesses_read_model = fishing_ground_businesses_read_model
        end

        link :self do
          base_uri + "/api/fisherman-registrar"
        end

        link :"fishing-world" do
          base_uri + "/api/fishing-world"
        end

        collection :"registered-fishermen", class: Fisherman, embedded: true

        define_method :"registered-fishermen" do
          @fisherman_read_model.records.map { |fisherman_record| Fisherman.new(fisherman_record) }
        end

        collection :"fishing-grounds-available-to-join", class: FishingGround, embedded: true

        define_method :"fishing-grounds-available-to-join" do
          @fishing_ground_read_model.records.map { |fishing_ground_record|
            FishingGround.new(
              base_uri,
              fishing_ground_record.merge(
                fishing_ground_businesses: @fishing_ground_businesses_read_model.records_for(
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
