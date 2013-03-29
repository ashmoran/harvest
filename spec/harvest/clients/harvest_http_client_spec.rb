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

      let(:test_fisherman_uuid) { UUIDTools::UUID.parse("399bb7de-94c6-11e2-a3e1-60334bfffe90") }
      let!(:fisherman_registrar_post_request) {
        stub_request(:post, fisherman_registrar_uri).to_return(
          # Duplicated with the server resource!
          body: { uuid: test_fisherman_uuid.to_s }.to_json
        )
      }

      let!(:fishing_world_post_request) {
        stub_request(:post, fishing_world_uri).to_return(
          # Duplicated with the server resource!
          body: { uuid: test_fishing_ground_uuid.to_s }.to_json
        )
      }

      let(:test_fishing_ground_uuid) { UUIDTools::UUID.parse("3f7a8ce0-959b-11e2-91ee-60334bfffe90") }
      let(:fishing_ground_uri) { root_uri + "/fishing-ground/#{test_fishing_ground_uuid}" }

      let!(:fishing_ground_get_request) {
        stub_request(:get, fishing_ground_uri).to_return(
          # body: '{"location":"at_fishing_ground","uuid":"3f7a8ce0-959b-11e2-91ee-60334bfffe90","name":"The Atlantic Ocean","starting_year":2012,"current_year":2013,"fishing_ground_businesses":[]}'
          body: HTTP::Representations::FishingGround.new(
            base_uri,
            uuid: test_fishing_ground_uuid,
            name: "The Atlantic Ocean",
            starting_year: 2012,
            current_year: 2013,
            fishing_ground_businesses: fishing_ground_businesses_read_model.records_for
          ).to_json
        )
      }
      # Frenetic correctly (but unhelpfully) fails on an empty body if the status isn't No Content
      let!(:fishing_ground_delete_request) {
        stub_request(:delete, fishing_ground_uri).to_return(status: 204)
      }

      let(:start_fishing_uri) { fishing_ground_uri + "/start_fishing" }
      let!(:start_fishing_post_request) {
        stub_request(:post, start_fishing_uri).to_return(status: 204)
      }

      let(:send_boat_out_to_sea_uri) { fishing_ground_uri + "/order" }
      let!(:send_boat_out_to_sea_post_request) {
        stub_request(:post, send_boat_out_to_sea_uri).to_return(status: 204)
      }

      let(:end_current_year_uri) { fishing_ground_uri + "/year_end" }
      let!(:end_current_year_post_request) {
        stub_request(:post, end_current_year_uri).to_return(status: 204)
      }

      # TODO: self link in this resource
      let(:business_statistics_uri) { fishing_ground_uri + "/statistics" }
      let!(:business_statistics_get_request) {
        stub_request(:get, business_statistics_uri).to_return(
          body: HTTP::Representations::FishingGroundBusinessStatistics.new(
            fishing_business_statistics: [
              {
                fishing_ground_uuid: test_fishing_ground_uuid,
                fishing_business_uuid: test_fisherman_uuid,
                lifetime_fish_caught: 0,
                lifetime_profit: "$0"
              }
            ]
          ).to_json
        )
      }

      let(:fishing_business_application_uri) { fishing_ground_uri + "/join" }
      let!(:fishing_business_application_post_request) {
        stub_request(:post, fishing_business_application_uri).to_return(status: 204)
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
            client.close_fishing_ground(uuid: test_fishing_ground_uuid)
            expect(fishing_ground_delete_request).to have_been_made
          end

          describe "client-specific commands" do
            before(:each) do
              client.sign_up_fisherman(name: "Fisherman Name")
            end

            specify "#set_up_in_business_in" do
              client.set_up_in_business(fishing_ground_uuid: test_fishing_ground_uuid)
              expect(
                fishing_business_application_post_request.with(
                  body: HTTP::Representations::FishingBusinessApplication.new(
                    fisherman_uuid: test_fisherman_uuid
                  ).to_hash
                )
              ).to have_been_made
            end
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

          # We will also need to know what happens when this isn't a valid
          # fishing ground, and when it's valid but isn't allowed at this point
          # for whatever reasons
          #
          # This is more granular than the domain client spec
          describe "go_to_fishing_ground" do
            specify "request" do
              client.go_to_fishing_ground(test_fishing_ground_uuid)
              expect(fishing_ground_get_request).to have_been_made
            end

            specify "location" do
              expect {
                client.go_to_fishing_ground(test_fishing_ground_uuid)
              }.to change { client.location_name }.to(:at_fishing_ground)
            end
          end
        end
      end

      context "location: at_fishing_ground" do
        before(:each) do
          client.go_to_registrars_office
          client.sign_up_fisherman(name: "Fisherman Name")
          client.go_to_fishing_ground(test_fishing_ground_uuid)
        end

        its(:location_details) {
          should be == { fishing_ground_uuid: test_fishing_ground_uuid }
        }

        describe "movement" do
          describe "#go_to_fishing_ground" do
            it "is idempotent" do
              client.go_to_fishing_ground(test_fishing_ground_uuid)

              expect(client.location_name).to be == :at_fishing_ground
              expect(client.location_details).to be == { fishing_ground_uuid: test_fishing_ground_uuid }
            end
          end
        end

        describe "client-specific commands" do
          specify "#start_fishing" do
            client.start_fishing
            expect(start_fishing_post_request).to have_been_made
          end

          specify "#send_boat_out_to_sea" do
            # TODO: The server resource shouldn't give us this link before fishing has started
            client.send_boat_out_to_sea(order: 5)
            expect(
              # TODO: Relying on #to_hash is getting really confusing
              send_boat_out_to_sea_post_request.with(
                body: HTTP::Representations::FishingOrder.new(
                  fishing_business_uuid: test_fisherman_uuid,
                  order: 5
                ).to_hash
              )
            ).to have_been_made
          end

          specify "#end_current_year" do
            client.end_current_year
            expect(end_current_year_post_request).to have_been_made
          end
        end

        describe "views" do
          specify ":fishing_ground_businesses" do
            expect(client.fishing_ground_businesses).to be == [
              { uuid: "fake_business_uuid", fishing_business_name: "The Atlantic Ocean" }
            ]
          end

          describe ":business_statistics" do
            specify "request" do
              client.business_statistics
              expect(business_statistics_get_request).to have_been_made
            end

            specify "statistics" do
              expect(client.business_statistics).to be == {
                fishing_ground_uuid: test_fishing_ground_uuid,
                fishing_business_uuid: test_fisherman_uuid,
                lifetime_fish_caught: 0,
                lifetime_profit: "$0"
              }
            end
          end
        end
      end
    end
  end
end