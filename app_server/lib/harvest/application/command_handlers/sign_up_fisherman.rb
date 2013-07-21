module Harvest
  module Application
    module CommandHandlers
      class SignUpFisherman
        def initialize(dependencies)
          @fisherman_registrar = dependencies.fetch(:fisherman_registrar)
        end

        def handle_sign_up_fisherman(command, response_port: required(:response_port))
          # It would be nice if we had a way of automatically extracting the correct
          # attributes from the command
          fisherman = Domain::Fisherman.create(username: command.username)
          @fisherman_registrar.register(fisherman)
          response_port.fishing_application_succeeded(uuid: fisherman.uuid)
        end

        def _new_sign_up_fisherman(command_attributes)
          fisherman = Domain::Fisherman.create(command_attributes)
          validator = FishermanValidator.new # FishermanRegistrar?
          validator.validate_for_registration(fisherman, notify: self)
        end

        def _fisherman_valid(details)
          @fisherman_registrar.register(fisherman)
          response_port.fishing_application_successful(details)
        end

        def _username_invalid(details)
          response_port.fishing_application_invalid(details) # ?
        end

        def _username_taken(details)
          response_port.fishing_application_invalid(details) # ?
        end

        def _email_address_invalid(details)
          response_port.fishing_application_invalid(details) # ?
        end

        def _email_address_taken(details)
          response_port.fishing_application_invalid(details) # ?
        end
      end
    end
  end
end