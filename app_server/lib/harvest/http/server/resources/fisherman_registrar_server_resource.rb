require 'json'

module Harvest
  module HTTP
    module Server
      module Resources
        class FishermanRegistrarServerResource < Resource
          def trace?
            true
          end

          def content_types_provided
            [['application/hal+json', :to_json]]
          end

          def allowed_methods
            %W[ GET POST ]
          end

          def malformed_request?
            JSON.parse(request.body)
            _malformed = false
          rescue JSON::ParserError
            render_json_error_response(
              error: "malformed_request",
              message: "Request body contained malformed JSON"
            )
            _malformed = true
          end

          def __new_process_post__
            command_bus.send(fishing_application, response_port: self)
          end

          def sign_up_fisherman_succeeded
            response.body = { uuid: fisherman_uuid }.to_json
            true
          end

          def fishing_application_invalid(details)

            # false
          end

          def fishing_application_conflicts(details)

            # false
          end

          def process_post
            fishing_application = Domain::Commands.build(
              :sign_up_fisherman, JSON.parse(request.body.to_s).symbolize_keys
            )

            # WIP

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

          def handle_exception(error)
            case error
            when Realm::Messaging::MessagePropertyError
              render_json_error_response(
                error: "invalid_command_format", message: error.message
              )

              # Unprocessable Entity, not in Webmachine as this status code is from WebDAV,
              # but it's gaining traction to indicate a semantic error rather than a syntactic
              # error (400)
              422
            else
              super
            end
          end

          private

          def render_json_error_response(error: required('error'), message: required('message'))
            response.headers['Content-Type'] = "application/json"
            response.body = {
              "error"   => error,
              "message" => message
            }.to_json
          end

          # http://stackoverflow.com/questions/13250447/can-i-have-required-named-parameters-in-ruby-2-x
          def required(arg)
            raise ArgumentError.new("Required keyword argument missing: #{arg}")
          end
        end
      end
    end
  end
end
