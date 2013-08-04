require 'spec_helper'

require 'harvest/domain'
require 'harvest/http/representations'
require 'harvest/http/server/resources'

module Harvest
  module HTTP
    module Server
      module Resources
        describe FishermanRegistrarServerResource, type: :resource do
          let(:resource_route) { [ ] }

          let(:request_method) { 'POST' }
          let(:request_path) { '/' }

          before(:each) do
            command_bus.stub(:send, &command_bus_send_behaviour)
          end

          before(:each) do
            dispatch_request
          end

          context "malformed request JSON" do
            let(:command_bus_send_behaviour) {
              -> { raise "CommandBus#send should not be called" }
            }

            let(:request_body) { "{ this is not JSON" }

            its(:code) { should be == 400 }

            specify "content type" do
              expect(response).to have_content_type("application/json")
            end

            specify "body" do
              expect(JSON.parse(response.body)).to be == {
                "error"   => "malformed_request",
                "message" => "Request body contained malformed JSON"
              }
            end
          end

          context "well-formed but invalid request" do
            let(:command_bus_send_behaviour) {
              -> { raise "CommandBus#send should not be called" }
            }

            let(:request_body) { '{ "todo": "next" }' }

            its(:code) { should be == 422 }

            specify "content type" do
              expect(response).to have_content_type("application/json")
            end

            describe "body" do
              subject(:parsed_body) { JSON.parse(response.body) }

              specify "error" do
                expect(parsed_body["error"]).to be == "invalid_command_format"
              end

              specify "message" do
                expect(parsed_body["message"]).to match(/Attributes did not match MessageType/)
              end
            end
          end

          context "unhandled command" do
            let(:fake_message) {
              double(Realm::Messaging::Message, message_type: :fake_message_type)
            }
            let(:command_bus_send_behaviour) {
              -> { raise Realm::Messaging::UnhandledMessageError.new(fake_message) }
            }

            let(:request_body) {
              {
                "username"      =>  "valid_username",
                "email_address" =>  "valid.email@example.com",
                "password"      =>  "valid password"
              }.to_json
            }

            # It's a shame 501 can't be used here, but that implies we can't handle
            # POST for any resource, rather than just the one with the unimplemented
            # command handler
            its(:code) { should be == 500 }

            specify "content type" do
              expect(response).to have_content_type("application/json")
            end

            describe "body" do
              subject(:parsed_body) { JSON.parse(response.body) }

              specify "error" do
                expect(parsed_body["error"]).to be == "unhandled_command"
              end

              specify "message" do
                expect(parsed_body["message"]).to match(
                  /The server has not been configured to perform command "fake_message_type"/
                )
              end
            end
          end

          context "domain-disallowed request (invalid according to domain validation)" do
            # Have to hack UUID until we generalise Realm's messaging system
            let(:request_body) {
              {
                "username"      =>  "invalid username!",
                "email_address" =>  "valid.email@example.com",
                "password"      =>  "valid password"
              }.to_json
            }

            let(:command_bus_send_behaviour) {
              -> (message, dependencies) {
                response_port = dependencies.fetch(:response_port)
                response_port.fishing_application_invalid(message: "Invalid username")
              }
            }

            specify "command sent" do
              expect(command_bus).to have_received(:send).with(
                message_matching(
                  message_type:   :sign_up_fisherman,
                  username:       "invalid username!",
                  email_address:  "valid.email@example.com",
                  password:       "valid password"
                ),
                # Please, pass `self` here...
                response_port: kind_of(Webmachine::Resource)
              )
            end

            its(:code) { should be == 422 }

            specify "content type" do
              expect(response).to have_content_type("application/json")
            end

            describe "body" do
              subject(:parsed_body) { JSON.parse(response.body) }

              specify "error" do
                expect(parsed_body["error"]).to be == "command_failed_validation"
              end

              specify "message" do
                expect(parsed_body["message"]).to match(/Invalid username/)
              end
            end
          end

          context "conflicting command (eg duplicate username)" do
            let(:request_body) {
              {
                "username"      =>  "duplicate_username",
                "email_address" =>  "valid.email@example.com",
                "password"      =>  "valid password"
              }.to_json
            }

            let(:command_bus_send_behaviour) {
              -> (message, dependencies) {
                response_port = dependencies.fetch(:response_port)
                response_port.fishing_application_conflicts(message: "Username taken")
              }
            }

            specify "command sent" do
              expect(command_bus).to have_received(:send).with(
                message_matching(
                  message_type:   :sign_up_fisherman,
                  username:       "duplicate_username",
                  email_address:  "valid.email@example.com",
                  password:       "valid password"
                ),
                response_port: kind_of(Webmachine::Resource)
              )
            end

            # This is a bit of a hack as conflicts are intended per-resource,
            # maybe we should use post_is_create and see if we can treat it as PUT?
            # (We'd still have the issue that the conlict is cross-resource though.)
            its(:code) { should be == 409 }

            specify "content type" do
              expect(response).to have_content_type("application/json")
            end

            describe "body" do
              subject(:parsed_body) { JSON.parse(response.body) }

              specify "error" do
                expect(parsed_body["error"]).to be == "command_failed_validation"
              end

              specify "message" do
                expect(parsed_body["message"]).to match(/Username taken/)
              end
            end
          end

          context "successful create" do
            let(:request_body) {
              {
                "username"      =>  "username",
                "email_address" =>  "valid.email@example.com",
                "password"      =>  "valid password"
              }.to_json
            }

            let(:command_bus_send_behaviour) {
              -> (message, dependencies) {
                response_port = dependencies.fetch(:response_port)
                response_port.fishing_application_succeeded(uuid: "some_uuid")
              }
            }

            specify "command sent" do
              expect(command_bus).to have_received(:send).with(
                message_matching(
                  message_type:   :sign_up_fisherman,
                  username:       "username",
                  email_address:  "valid.email@example.com",
                  password:       "valid password"
                ),
                response_port: kind_of(Webmachine::Resource)
              )
            end

            # In future we may create a new resource, and then return a 201
            its(:code) { should be == 200 }

            specify "content type" do
              expect(response).to have_content_type("application/json")
            end

            describe "body" do
              subject(:parsed_body) { JSON.parse(response.body) }

              specify "uuid" do
                expect(parsed_body["uuid"]).to be == "some_uuid"
              end
            end
          end
        end
      end
    end
  end
end
