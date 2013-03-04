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

          # TODO: Separate these resources?
          def process_post
            uuid, action = request.path_tokens
            case action
            when "join"
              # TODO: Re-use the resource?
              harvest_app.poseidon.set_fisherman_up_in_business(
                fisherman_uuid: UUIDTools::UUID.parse(JSON.parse(request.body.to_s)["fisherman_uuid"]),
                fishing_ground_uuid: UUIDTools::UUID.parse(uuid)
              )
              true
            when "start_fishing"
              harvest_app.poseidon.start_fishing(uuid: UUIDTools::UUID.parse(uuid))
              true
            when "order"
              order = JSON.parse(request.body.to_s)
              harvest_app.poseidon.send_boat_out_to_sea(
                fishing_business_uuid: UUIDTools::UUID.parse(order["fishing_business_uuid"]),
                fishing_ground_uuid: UUIDTools::UUID.parse(uuid),
                order: order["order"]
              )
              true
            when "year_end"
              harvest_app.poseidon.end_year_in_fishing_ground(uuid: UUIDTools::UUID.parse(uuid))
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
