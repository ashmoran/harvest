module Harvest
  module HTTP
    module Server
      module Resources
        class HarvestServerResource < Resource
          def content_types_provided
            [['application/hal+json', :to_json]]
          end

          def trace?
            false
          end

          def to_json
            Representations::HarvestHome.new(base_uri: base_uri).to_json
          end
        end
      end
    end
  end
end
