require 'spec_helper'

require 'harvest/http/server/resources'

module Harvest
  module HTTP
    module Server
      module Resources
        describe EmailAddressResource, type: :resource do
          let(:resource_route) { [ :email_address ] }

          let(:request_method) { 'GET' }
          let(:request_path) { '/test@example.com' }
          let(:request_body) { nil }

          let(:parsed_response_body) { JSON.parse(response.body) }

          # Watch out: direct dependency on Realm::IdAccess
          let(:user_service) {
            double(Realm::Systems::IdAccess::Domain::UserService,
              email_address_available?: email_address_available?
            )
          }

          before(:each) do
            harvest_app.application_services[:user_service] = user_service
            dispatch_request
          end

          context "in all cases" do
            let(:email_address_available?) { nil }

            it "queries the service" do
              expect(user_service).to have_received(:email_address_available?).with("test@example.com")
            end
          end

          context "email address is available" do
            let(:email_address_available?) { true }

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

          context "email address is not available" do
            let(:email_address_available?) { false }

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
