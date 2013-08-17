require 'spec_helper'

require 'harvest/domain/events'
require 'harvest/domain/commands'
require 'harvest/domain/fisherman'
require 'harvest/domain/fisherman_registrar'

require 'harvest/application/command_handlers/sign_up_fisherman'

module Harvest
  module Application
    module CommandHandlers
      describe SignUpFisherman do
        let(:fisherman_registrar) {
          double(Domain::FishermanRegistrar, register: nil)
        }

        let(:fisherman) {
          double(Domain::Fisherman, uuid: :fisherman_uuid, assign_user: nil)
        }

        before(:each) do
          Domain::Fisherman.stub(create: fisherman)
        end

        let(:command) {
          Harvest::Domain::Commands.build(
            :sign_up_fisherman,
            username:       "username",
            email_address:  "email@example.com",
            password:       "password"
          )
        }

        let(:command_bus) {
          double(Realm::Messaging::Bus::MessageBus, send: command_result)
        }

        let(:response_port) {
          double(
            "Response Port",
            fishing_application_succeeded:  nil,
            fishing_application_invalid:    nil,
            fishing_application_conflicts:  nil
          )
        }

        subject(:handler) {
          SignUpFisherman.new(
            command_bus:          command_bus,
            fisherman_registrar:  fisherman_registrar
          )
        }

        describe "#sign_up_fisherman" do
          def sign_up_fisherman
            handler.handle_sign_up_fisherman(command, response_port: response_port)
          end

          before(:each) do
            sign_up_fisherman
          end

          # In general we don't want one application service depending
          # on another, but it's acceptible for this context, for now
          describe "creating a user" do
            # This context is a hack to avoid re-testing the user created
            describe "generally" do
              let(:command_result) {
                Realm::Messaging::FakeMessageResponse.new(
                  # It doesn't matter what we resolve with here, it's ignored
                  resolve_with: {
                    message_type_name: :user_created,
                    args:              { uuid: "some_uuid" }
                  }
                )
              }

              it "sends a command to create a user" do
                expect(command_bus).to have_received(:send).with(
                  message_matching(
                    message_type_name:  :sign_up_user,
                    username:           "username",
                    email_address:      "email@example.com",
                    password:           "password"
                  )
                )
              end
            end

            context "success" do
              let(:command_result) {
                Realm::Messaging::FakeMessageResponse.new(
                  resolve_with: {
                    message_type_name: :user_created,
                    args:              { uuid: "some_uuid" }
                  }
                )
              }

              it "makes a Fisherman" do
                # Note: not using the rest of the credentials until we have a separate
                # user/login management system
                expect(Domain::Fisherman).to have_received(:create).with(
                  username: "username"
                )
              end

              it "assigns the user" do
                expect(fisherman).to have_received(:assign_user).with(uuid: "some_uuid")
              end

              it "saves the Fisherman" do
                expect(fisherman_registrar).to have_received(:register).with(fisherman)
              end

              it "notifies the listener of the Fisherman's UUID" do
                expect(response_port).to have_received(:fishing_application_succeeded).with(
                  uuid: :fisherman_uuid
                )
              end
            end

            context "invalid" do
              let(:command_result) {
                Realm::Messaging::FakeMessageResponse.new(
                  resolve_with: {
                    message_type_name: :user_invalid,
                    args:              { message: "Invalid username" }
                  }
                )
              }

              it "makes no fisherman" do
                expect(Domain::Fisherman).to_not have_received(:create)
              end

              it "notifies the listener" do
                expect(response_port).to have_received(:fishing_application_invalid).with(message: "Invalid username")
              end
            end

            context "conflict" do
              let(:command_result) {
                Realm::Messaging::FakeMessageResponse.new(
                  resolve_with: {
                    message_type_name: :user_conflicts,
                    args:              { message: "Username taken" }
                  }
                )
              }

              it "makes no fisherman" do
                expect(Domain::Fisherman).to_not have_received(:create)
              end

              it "notifies the listener" do
                expect(response_port).to have_received(:fishing_application_conflicts).with(message: "Username taken")
              end
            end
          end
        end
      end
    end
  end
end