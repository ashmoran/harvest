require 'spec_helper'

require 'harvest/http/server/resources'

module Harvest
  module HTTP
    module Server
      module Resources
        describe UsernameResource, type: :resource do
          let(:resource_route) { [ :username ] }

          let(:request_method) { 'GET' }
          let(:request_path) { '/test_username' }
          let(:request_body) { nil }

          let(:parsed_response_body) { JSON.parse(response.body) }

          # Watch out: direct dependency on Realm::IdAccess
          let(:user_service) {
            double(Realm::Systems::IdAccess::Domain::UserService,
              username_available?: username_available?
            )
          }

          before(:each) do
            harvest_app.application_services[:user_service] = user_service
            dispatch_request
          end

          context "in all cases" do
            let(:username_available?) { nil }

            it "queries the service" do
              expect(user_service).to have_received(:username_available?).with("test_username")
            end
          end

          context "username is available" do
            let(:username_available?) { true }

            its(:code) { should be == 200 }

            specify "content type" do
              expect(response).to have_content_type("application/json")
            end

            specify "body" do
              expect(parsed_response_body).to be == {
                "status" => "available"
              }
            end
          end

          context "username is not available" do
            let(:username_available?) { false }

            its(:code) { should be == 200 }

            specify "content type" do
              expect(response).to have_content_type("application/json")
            end

            specify "body" do
              expect(parsed_response_body).to be == {
                "status" => "unavailable"
              }
            end
          end
        end
      end
    end
  end
end
