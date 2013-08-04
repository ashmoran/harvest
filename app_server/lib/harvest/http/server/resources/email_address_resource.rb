module Harvest
  module HTTP
    module Server
      module Resources
        class EmailAddressResource < Resource
          def content_types_provided
            [['application/json', :to_json]]
          end

          def allowed_methods
            %W[ GET ]
          end

          def resource
            { status: email_address_text_status }
          end

          def to_json
            resource.to_json
          end

          private

          def email_address_text_status
            if user_service.email_address_available?(request_email_address)
              "available"
            else
              "unavailable"
            end
          end

          def user_service
            harvest_app.application_services[:user_service]
          end

          def request_email_address
            request.path_info[:email_address]
          end
        end
      end
    end
  end
end
