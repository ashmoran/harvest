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
          @command_bus.send(
            # I think we need to make this constant lookup longer somehow
            Realm::Systems::IdAccess::Application::Commands.build(
              :sign_up_user,
              # Some way of extracting attributes would be nice, maybe
              username:       command.username,
              email_address:  command.email_address,
              password:       command.password,
            )
          ).on(
            user_created: ->(result) {
              # It would be nice if we had a way of automatically extracting the correct
              # attributes from the command
              Domain::Fisherman.create(username: command.username).tap do |fisherman|
                @fisherman_registrar.register(fisherman)
                fisherman.assign_user(uuid: result[:uuid])
                response_port.fishing_application_succeeded(uuid: fisherman.uuid)
              end
            },
            user_invalid: ->(result) {
              response_port.fishing_application_invalid(result)
            },
            user_conflicts: ->(result) {
              response_port.fishing_application_conflicts(result)
            }
          )
        end
      end
    end
  end
end