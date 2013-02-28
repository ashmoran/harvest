module Harvest
  module HTTP
    module Representations
      class FishingGround
        include Roar::Representer::JSON::HAL

        attr_reader :base_uri

        # Duplicated with the read model
        property :uuid,           type: String # Not really!
        property :name,           type: String
        property :starting_year,  type: Integer
        property :current_year,   type: Integer
        attr_accessor :uuid, :name, :starting_year, :current_year

        link :self do
          base_uri + "/api/fishing-ground/" + uuid
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
