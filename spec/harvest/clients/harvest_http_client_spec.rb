require 'spec_helper'

require 'harvest/clients/harvest_http_client'

module Harvest
  module Clients
    describe HarvestHTTPClient do
      let(:base_uri)                { "http://fakeharvest.net" }
      let(:root_uri)                { base_uri + "/api" }
      let(:fisherman_registrar_uri) { root_uri + "/fisherman-registrar" }
      let(:fishing_world_uri)       { root_uri + "/fishing-world" }

      subject(:client) { HarvestHTTPClient.new(root_uri) }

      let(:fisherman_read_model) {
        mock("BAD DESIGN", records: [ { name: "Fisherman Name" } ])
      }
      let(:fishing_ground_read_model) {
        mock("BAD DESIGN", records: [ { uuid: "3f7a8ce0-959b-11e2-91ee-60334bfffe90", name: "The Atlantic Ocean" } ])
      }
      let(:fishing_ground_businesses_read_model) {
        mock("GODAWFUL DESIGN", records_for: [ { uuid: "fake_business_uuid", fishing_business_name: "The Atlantic Ocean" } ])
      }

      let!(:root_get_request) {
        stub_request(:get, root_uri).to_return(
          body: HTTP::Representations::HarvestHome.new(base_uri: base_uri).to_json
        )
      }

      let!(:fisherman_registrar_get_request) {
        stub_request(:get, fisherman_registrar_uri).to_return(
          body: HTTP::Representations::FishermanRegistrar.new(
            base_uri,
            fisherman_read_model:                 fisherman_read_model,
            fishing_ground_read_model:            fishing_ground_read_model,
            fishing_ground_businesses_read_model: fishing_ground_businesses_read_model
          ).to_json
        )
      }

      let!(:fisherman_registrar_post_request) {
        stub_request(:post, fisherman_registrar_uri).to_return(
          # Duplicated with the server resource!
          body: { uuid: "399bb7de-94c6-11e2-a3e1-60334bfffe90" }.to_json
        )
      }

      let!(:fishing_world_post_request) {
        stub_request(:post, fishing_world_uri).to_return(
          # Duplicated with the server resource!
          body: { uuid: "3f7a8ce0-959b-11e2-91ee-60334bfffe90" }.to_json
        )
      }

      let(:fishing_ground_uri) { root_uri + "/fishing-ground/3f7a8ce0-959b-11e2-91ee-60334bfffe90" }

      # Frenetic correctly (but unhelpfully) fails on an empty body if the status isn't No Content
      let!(:fishing_ground_delete_request) {
        stub_request(:delete, fishing_ground_uri).to_return(status: 204)
      }

      before(:each) do
        client.start
      end

      describe "reloading" do
        it "is done in a sane way" do
          pending "look for reload code in the client and also in the Cucumber steps"
        end
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

          specify "#open_fishing_ground" do
            client.open_fishing_ground(
              name:                 "The Atlantic Ocean",
              starting_population:  40,
              carrying_capacity:    50,
              starting_year:        2012,
              lifetime:             10,
              order_fulfilment:     :random
            )
            expect(
              fishing_world_post_request.with(
                body: HTTP::Representations::FishingGroundApplication.new(
                  name:                 "The Atlantic Ocean",
                  starting_population:  40,
                  carrying_capacity:    50,
                  starting_year:        2012,
                  lifetime:             10,
                  order_fulfilment:     :random
                ).to_json
              )
            ).to have_been_made
          end

          specify "#close_fishing_ground" do
            # Currently re-using the test UUID returned from another post request
            # TODO: This really tripped me up - if you don't pass in a UUID object, it breaks.
            # Need to decide what to do about typing command attributes.
            client.close_fishing_ground(uuid: UUIDTools::UUID.parse("3f7a8ce0-959b-11e2-91ee-60334bfffe90"))
            expect(fishing_ground_delete_request).to have_been_made
          end
        end

        describe "views" do
          specify ":registered_fishermen" do
            expect(client.registered_fishermen).to be == [ { name: "Fisherman Name" } ]
          end

          # TODO: Decide if this should be moved out of the Registrar's Office (but if so, where?)
          specify ":fishing_grounds_available_to_join" do
            # Hacky test for now, as this is an ugly nested embedded resource
            expect(
              client.fishing_grounds_available_to_join.map { |ground| ground[:name] }
            ).to be == [ "The Atlantic Ocean" ]
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