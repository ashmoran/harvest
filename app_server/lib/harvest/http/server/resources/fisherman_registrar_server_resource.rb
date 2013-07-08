module Harvest
  module HTTP
    module Server
      module Resources
        class FishermanRegistrarServerResource < Resource
          def trace?
            false
          end

          def content_types_provided
            [['application/hal+json', :to_json]]
          end

          def allowed_methods
            %W[ GET POST ]
          end

          def process_post
            fishing_application = Representations::FishingApplication.from_json(request.body.to_s)
            fisherman_uuid = harvest_app.poseidon.sign_up_fisherman(
              fishing_application.to_hash.symbolize_keys
            )

            response.body = { uuid: fisherman_uuid }.to_json
            true
          end

          def to_json
            Representations::FishermanRegistrar.new(
              base_uri,
              fisherman_read_model:                 harvest_app.read_models[:registered_fishermen],
              fishing_ground_read_model:            harvest_app.read_models[:fishing_grounds_available_to_join],
              fishing_ground_businesses_read_model: harvest_app.read_models[:fishing_ground_businesses],
            ).to_json
          end
        end
      end
    end
  end
end