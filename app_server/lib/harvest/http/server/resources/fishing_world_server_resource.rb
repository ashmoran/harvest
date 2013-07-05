module Harvest
  module HTTP
    module Server
      module Resources
        class FishingWorldServerResource < Resource
          def trace?
            true
          end

          def content_types_provided
            [['application/hal+json', :to_json]]
          end

          def allowed_methods
            %W[ GET POST ]
          end

          def process_post
            fishing_ground_application = Representations::FishingGroundApplication.from_json(request.body.to_s)
            uuid = harvest_app.poseidon.open_fishing_ground(fishing_ground_application.to_hash.symbolize_keys)
            # Hack the UUID back to the client until we know how best to handle command POST responses
            response.body = { uuid: uuid }.to_json
            true
          end

          def to_json
            Representations::FishingWorld.new(
              base_uri,
              fishing_grounds_available_to_join:  harvest_app.read_models[:fishing_grounds_available_to_join],
              fishing_ground_businesses:          harvest_app.read_models[:fishing_ground_businesses]
            ).to_json
          end
        end
      end
    end
  end
end
