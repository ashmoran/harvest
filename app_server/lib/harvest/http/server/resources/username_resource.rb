module Harvest
  module HTTP
    module Server
      module Resources
        class UsernameResource < Resource
          def content_types_provided
            [['application/json', :to_json]]
          end

          def allowed_methods
            %W[ GET ]
          end

          def resource
            { status: username_text_status }
          end

          def to_json
            resource.to_json
          end

          private

          def username_text_status
            if user_service.username_available?(request_username)
              "available"
            else
              "unavailable"
            end
          end

          def user_service
            harvest_app.application_services[:user_service]
          end

          def request_username
            request.path_info[:username]
          end
        end
      end
    end
  end
end
