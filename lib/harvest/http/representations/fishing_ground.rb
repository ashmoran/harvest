module Harvest
  module HTTP
    module Representations
      class FishingGround
        include Roar::Representer::JSON::HAL

        attr_reader :base_uri
        attr_writer :fishing_ground_businesses

        # Pretend to be a state_machine state machine
        property :location
        def location
          "at_fishing_ground"
        end

        # Duplicated with the read model
        property :uuid,           type: String # Not really!
        property :name,           type: String
        property :starting_year,  type: Integer
        property :current_year,   type: Integer
        attr_accessor :uuid, :name, :starting_year, :current_year

        link :self do
          base_uri + "/api/fishing-ground/" + uuid
        end

        link :join do
          base_uri + "/api/fishing-ground/" + uuid + '/join'
        end

        link :start_fishing do
          base_uri + "/api/fishing-ground/" + uuid + '/start_fishing'
        end

        link :order do
          base_uri + "/api/fishing-ground/" + uuid + '/order'
        end

        link :year_end do
          base_uri + "/api/fishing-ground/" + uuid + '/year_end'
        end

        link :statistics do
          base_uri + "/api/fishing-ground/" + uuid + '/statistics'
        end

        collection :"fishing-ground-businesses", embedded: true

        define_method :"fishing-ground-businesses" do
          @fishing_ground_businesses
        end

        # The default ROAR #from_hash doesn't symbolize keys
        def initialize(base_uri, attributes = (blank=true; nil))
          @base_uri = base_uri

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
