require 'spec_helper'

require 'harvest/clients/harvest_http_client'

module Harvest
  module Clients
    describe HarvestHTTPClient do
      let(:base_uri) { "http://fakeharvest.net" }
      let(:root_uri) { base_uri + "/api" }
      let(:fisherman_registrar_uri) { root_uri + "/fisherman-registrar" }

      subject(:client) { HarvestHTTPClient.new(root_uri) }

      let(:fisherman_read_model) { mock("BAD DESIGN", records: [ { name: "Fisherman Name" } ]) }

      let!(:root_get_request) {
        stub_request(:get, root_uri).to_return(
          body: HTTP::Representations::HarvestHome.new(base_uri: base_uri).to_json
        )
      }

      let!(:fisherman_registrar_get_request) {
        stub_request(:get, fisherman_registrar_uri).to_return(
          body: HTTP::Representations::FishermanRegistrar.new(base_uri, fisherman_read_model).to_json
        )
      }

      let!(:fisherman_registrar_post_request) {
        stub_request(:post, fisherman_registrar_uri).to_return(
          # Duplicated with the server resource!
          body: { uuid: "399bb7de-94c6-11e2-a3e1-60334bfffe90" }.to_json
        )
      }

      before(:each) do
        client.start
      end

      context "new" do
        its(:location_name) { should be == :outside_registrars_office }
        its(:inspect) { should be == "<HarvestHTTPClient location=:outside_registrars_office>" }
      end

      describe "#go_to_registrars_office" do
        specify {
          expect {
            client.go_to_registrars_office
          }.to change {
            client.location_name
          }.from(:outside_registrars_office).to(:inside_registrars_office)
        }
      end

      context "location: inside_registrars_office" do
        before(:each) do
          client.go_to_registrars_office
          expect(client.location_name).to be == :inside_registrars_office # Sanity check
        end

        describe "commands" do # Began life as "command delegation"
          specify "#sign_up_fisherman" do
            client.sign_up_fisherman(name: "Fisherman Name")
            expect(
              fisherman_registrar_post_request.with(
                body: HTTP::Representations::FishingApplication.new(name: "Fisherman Name").to_hash
              )
            ).to have_been_made
          end

          # ...
        end

        describe "views" do
          specify ":registered_fishermen" do
            expect(client.registered_fishermen).to be == [ { name: "Fisherman Name" } ]
          end
        end

        describe "movement" do
          specify "go_to_registrars_office" do
            expect {
              client.go_to_registrars_office
            }.to_not change { client.location_name }
          end

          # ...
        end
      end
    end
  end
end