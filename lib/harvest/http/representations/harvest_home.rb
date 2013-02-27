module Harvest
  module HTTP
    module Representations
      class HarvestHome
        include Roar::Representer::JSON::HAL

        attr_reader :base_uri

        # Copied blindly from FishingApplication for now...
        def initialize(attributes = (blank=true; nil))
          @base_uri = attributes.fetch(:base_uri)
          if !blank
            # No properties yet!
          end
        end

        link :self do
          base_uri + "/api"
        end

        link :"fisherman-registrar" do
          base_uri + "/api/fisherman-registrar"
        end

        link :"fishing-world" do
          base_uri + "/api/fishing-world"
        end
      end
    end
  end
end
