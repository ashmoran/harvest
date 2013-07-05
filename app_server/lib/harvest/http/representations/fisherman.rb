module Harvest
  module HTTP
    module Representations
      class Fisherman
        include Roar::Representer::JSON::HAL

        property :name
        attr_reader :name

        def initialize(attributes)
          @name = attributes.fetch(:name)
        end
      end
    end
  end
end
