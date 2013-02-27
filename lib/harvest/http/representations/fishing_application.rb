module Harvest
  module HTTP
    module Representations
      class FishingApplication
        include Roar::Representer::JSON::HAL

        property :name
        attr_accessor :name

        def initialize(attributes = (blank=true; nil))
          if !blank
            @name = attributes.fetch(:name)
          end
        end
      end
    end
  end
end
