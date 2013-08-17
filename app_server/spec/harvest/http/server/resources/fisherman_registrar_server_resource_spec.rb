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

          let(:poseidon) {
            double("ApplicationService", sign_up_fisherman: command_response)
          }

          before(:each) do
            harvest_app.application_services[:poseidon] = poseidon
          end

          before(:each) do
            dispatch_request
          end

          context "malformed request JSON" do
            let(:request_body) { "{ this is not JSON" }

            its(:code) { should be == 400 }

            let(:command_response) { :_never_reached_ }

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
            let(:request_body) { '{ "invalid": "command" }' }

            # This is a bit nasty - as we're no longer creating the commands in the
            # resource, we have to know how to construct a MessagePropertyError in
            # the specs. A better solution will emerge later, I hope...
            let(:error) {
              Realm::Messaging::MessagePropertyError.new(:some_message_type, [:foo], [:bar])
            }

            let(:command_response) {
              Realm::Messaging::FakeMessageResponse.new(raise_error: error)
            }

            specify "command sent" do
              expect(poseidon).to have_received(:sign_up_fisherman).with(
                invalid: "command"
              )
            end

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
              double(Realm::Messaging::Message, message_type_name: :fake_message_type)
            }

            let(:request_body) {
              {
                "username"      =>  "valid_username",
                "email_address" =>  "valid.email@example.com",
                "password"      =>  "valid password"
              }.to_json
            }

            let(:command_response) {
              Realm::Messaging::FakeMessageResponse.new(
                raise_error: Realm::Messaging::UnhandledMessageError.new(fake_message)
              )
            }

            specify "command sent" do
              expect(poseidon).to have_received(:sign_up_fisherman).with(
                username:       "valid_username",
                email_address:  "valid.email@example.com",
                password:       "valid password"
              )
            end


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
                expect(parsed_body["error"]).to be == "unhandled_message"
              end

              specify "message" do
                expect(parsed_body["message"]).to match(
                  /The server has not been configured to handle "fake_message_type"/
                )
              end
            end
          end

          context "domain-disallowed request (invalid according to domain validation)" do
            let(:request_body) {
              {
                "username"      =>  "invalid username!",
                "email_address" =>  "valid.email@example.com",
                "password"      =>  "valid password"
              }.to_json
            }

            let(:command_response) {
              Realm::Messaging::FakeMessageResponse.new(
                resolve_with: {
                  message_type_name: :fishing_application_invalid,
                  args:              { message: "Invalid username" }
                }
              )
            }

            specify "command sent" do
              expect(poseidon).to have_received(:sign_up_fisherman).with(
                username:       "invalid username!",
                email_address:  "valid.email@example.com",
                password:       "valid password"
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

            let(:command_response) {
              Realm::Messaging::FakeMessageResponse.new(
                resolve_with: {
                  message_type_name: :fishing_application_conflicts,
                  args:              { message: "Username taken" }
                }
              )
            }

            specify "command sent" do
              expect(poseidon).to have_received(:sign_up_fisherman).with(
                username:       "duplicate_username",
                email_address:  "valid.email@example.com",
                password:       "valid password"
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

            let(:command_response) {
              Realm::Messaging::FakeMessageResponse.new(
                resolve_with: {
                  message_type_name: :fishing_application_succeeded,
                  args:              { uuid: "some_uuid" }
                }
              )
            }

            specify "command sent" do
              expect(poseidon).to have_received(:sign_up_fisherman).with(
                username:       "username",
                email_address:  "valid.email@example.com",
                password:       "valid password"
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
