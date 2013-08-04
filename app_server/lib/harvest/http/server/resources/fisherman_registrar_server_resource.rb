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
            # This is probably proof we need to split the GET and POST requests
            # into separate resources
            return false if request.get?

            # Send to_s because we might have a LazyRequestBody
            JSON.parse(request.body.to_s)
            false
          rescue JSON::ParserError
            render_json_error_response(
              error: "malformed_request",
              message: "Request body contained malformed JSON"
            )
            true
          end

          def command_type
            :sign_up_fisherman
          end

          def process_post
            fishing_application = Domain::Commands.build(
              command_type, JSON.parse(request.body.to_s).symbolize_keys
            )

            harvest_app.command_bus.send(fishing_application, response_port: self)

            command_status
          end

          def command_status
            if @command_status.nil?
              raise "We never determined if the POST request was successful"
            else
              @command_status
            end
          end

          def fishing_application_succeeded(command_response)
            response.headers['Content-Type'] = "application/json"
            response.body = command_response.to_json
            @command_status = true
          end

          def fishing_application_invalid(message: required(:message))
            render_json_error_response(
              error: "command_failed_validation", message: message
            )
            @command_status = 422
          end

          def fishing_application_conflicts(message: required(:message))
            render_json_error_response(
              error: "command_failed_validation", message: message
            )
            @command_status = 409
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
              # error (400).
              # Maybe it would make more sense to use 400 for unconstructable commands though,
              # and 422 only for when domain validation fails.
              422
            when Realm::Messaging::UnhandledMessageError
              render_json_error_response(
                error:    "unhandled_command",
                message:  %'The server has not been configured to perform command "#{error.domain_message.message_type}"'
              )
              500
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
        end
      end
    end
  end
end
