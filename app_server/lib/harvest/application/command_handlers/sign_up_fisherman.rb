require 'realm/systems/id_access/application/commands'

module Harvest
  module Application
    module CommandHandlers
      class SignUpFisherman
        def initialize(dependencies)
          # Command bus is a questionable dependency
          @command_bus          = dependencies.fetch(:command_bus)
          @fisherman_registrar  = dependencies.fetch(:fisherman_registrar)
        end

        def handle_sign_up_fisherman(command, response_port: required(:response_port))
          listener =
            UserCreatedListener.new(
              username:             command.username,
              fisherman_registrar:  @fisherman_registrar,
              response_port:        response_port
            )

          @command_bus.send(
            # I think we need to make this constant lookup longer somehow
            Realm::Systems::IdAccess::Application::Commands.build(
              :sign_up_user,
              # Some way of extracting attributes would be nice, maybe
              username:       command.username,
              email_address:  command.email_address,
              password:       command.password,
            ),
            response_port: listener
          )
        end

        # Because each command handler is currently reusable, we need to instantiate
        # something to handle each command response at runtime
        class UserCreatedListener
          def initialize(username: nil, fisherman_registrar: nil, response_port: nil)
            @username             = username
            @fisherman_registrar  = fisherman_registrar
            @response_port        = response_port
          end

          def user_created(command_response)
            # It would be nice if we had a way of automatically extracting the correct
            # attributes from the command
            Domain::Fisherman.create(username: @username).tap do |fisherman|
              @fisherman_registrar.register(fisherman)
              fisherman.assign_user(uuid: command_response[:uuid])
              @response_port.fishing_application_succeeded(uuid: fisherman.uuid)
            end
          end

          def user_invalid(command_response)
            @response_port.fishing_application_invalid(command_response)
          end

          def user_conflicts(command_response)
            @response_port.fishing_application_conflicts(command_response)
          end
        end
      end
    end
  end
end