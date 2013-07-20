require 'spec_helper'

require 'harvest/domain/events'
require 'harvest/domain/commands'
require 'harvest/domain/fisherman'
require 'harvest/domain/fisherman_registrar'
require 'harvest/domain/command_handlers/sign_up_fisherman'

module Harvest
  module Domain
    module CommandHandlers
      describe SignUpFisherman do
        let(:fisherman_registrar) {
          double(Domain::FishermanRegistrar, register: nil)
        }

        let(:fisherman) {
          double(Fisherman, uuid: :aggregate_root_uuid)
        }

        before(:each) do
          Domain::Fisherman.stub(create: fisherman)
        end

        let(:command) {
          Harvest::Domain::Commands.build(
            :sign_up_fisherman,
            uuid:           nil,
            username:       "username",
            email_address:  "email@example.com",
            password:       "password"
          )
        }

        let(:response_port) {
          double("Response Port", fishing_application_succeeded: nil)
        }

        subject(:handler) {
          SignUpFisherman.new(fisherman_registrar: fisherman_registrar)
        }

        describe "#sign_up_fisherman" do
          def sign_up_fisherman
            handler.handle_sign_up_fisherman(command, response_port: response_port)
          end

          before(:each) do
            sign_up_fisherman
          end

          it "makes a Fisherman" do
            # Note: not using the rest of the credentials until we have a separate
            # user/login management system
            expect(Domain::Fisherman).to have_received(:create).with(
              username: "username"
            )
          end

          it "saves the Fisherman" do
            expect(fisherman_registrar).to have_received(:register).with(fisherman)
          end

          it "returns the Fisherman's UUID" do
            expect(response_port).to have_received(:fishing_application_succeeded).with(
              uuid: :aggregate_root_uuid
            )
          end
        end
      end
    end
  end
end