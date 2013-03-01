module Harvest
  module HTTP
    module Server
      module Resources
        class FishingGroundServerResource < Resource
          def trace?
            false
          end

          def content_types_provided
            [['application/hal+json', :to_json]]
          end

          def allowed_methods
            %W[ POST DELETE ]
          end

          def process_post
            uuid, action = request.path_tokens
            case action
            when "join"
              harvest_app.poseidon.set_fisherman_up_in_business(
                fisherman_uuid: UUIDTools::UUID.parse(JSON.parse(request.body.to_s)["fisherman_uuid"]),
                fishing_ground_uuid: UUIDTools::UUID.parse(uuid)
              )
              true
            else
              # TODO: return an error code somehow
            end
          end

          def delete_resource
            harvest_app.poseidon.close_fishing_ground(uuid: UUIDTools::UUID.parse(request.path_tokens.first))
          end
        end
      end
    end
  end
end
