require 'spec_helper'

require 'harvest/clients/harvest_domain_client'

require 'harvest/app'
require 'harvest/poseidon'

module Harvest
  module Clients
    describe HarvestDomainClient do
      def mock_read_model(name, stubs = { })
        double(
          "Read Model :#{name}",
          {
            records:      :"#{name}_records",
            records_for:  :undefined_records_for,
            record_for:   :undefined_record_for
          }.merge(stubs)
        )
      end

      let(:poseidon) { double(Harvest::Poseidon, sign_up_fisherman: nil) }

      let(:fishing_ground_businesses) { mock_read_model("fishing_ground_businesses") }
      let(:business_statistics) { mock_read_model("fishing_businesses_statistics") }

      let(:read_models) {
        {
          registered_fishermen:               mock_read_model("registered_fishermen"),
          fishing_grounds_available_to_join:  mock_read_model("fishing_grounds_available_to_join"),
          fishing_ground_businesses:          fishing_ground_businesses,
          fishing_business_statistics:        business_statistics
        }
      }

      let(:app) {
        double(Harvest::App, poseidon: poseidon, read_models: read_models)
      }
      subject(:client) { HarvestDomainClient.new(app) }

      context "new" do
        its(:location_name) { should be == :outside_registrars_office }
        its(:inspect) { should be == "<HarvestDomainClient location=:outside_registrars_office>" }

        describe "#start" do
          it "does nothing, so we have the same interface as HarvestHTTPClient" do
            # RSpec 2.14 deprecation:
            # DEPRECATION: `expect { }.not_to raise_error(SpecificErrorClass)` is deprecated. Use `expect { }.not_to raise_error()` instead
            begin
              client.start
            rescue NoMethodError
              fail "Must respond to #start"
            rescue StandardError
              # We don't care about anything other errors for the purposes of this example
            end
          end
        end

        describe "#reload" do
          # TODO: Reload is not a concern users of the client should have!
          it "does nothing, so we have the same interface as HarvestHTTPClient" do
            # RSpec 2.14 deprecation:
            # DEPRECATION: `expect { }.not_to raise_error(SpecificErrorClass)` is deprecated. Use `expect { }.not_to raise_error()` instead
            begin
              client.reload
            rescue NoMethodError
              fail "Must respond to #reload"
            rescue StandardError
              # We don't care about anything other errors for the purposes of this example
            end
          end
        end
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

        describe "command delegation" do
          specify "#sign_up_fisherman" do
            poseidon.should_receive(:sign_up_fisherman).with(:command_arguments)
            client.sign_up_fisherman(:command_arguments)
          end

          specify "#open_fishing_ground" do
            poseidon.should_receive(:open_fishing_ground).with(:command_arguments)
            client.open_fishing_ground(:command_arguments)
          end

          specify "#close_fishing_ground" do
            poseidon.should_receive(:close_fishing_ground).with(:command_arguments)
            client.close_fishing_ground(:command_arguments)
          end

          # With authentication/authorization, we should probably
          # expect everything to move in here
          describe "client-specific commands" do
            before(:each) do
              poseidon.stub(sign_up_fisherman: :client_uuid)
              client.sign_up_fisherman(:unused_arguments)
            end

            # The original method was #set_up_in_business and expected a Fisherman UUID
            specify "#set_up_in_business" do
              poseidon.should_receive(:set_fisherman_up_in_business).with(
                fisherman_uuid: :client_uuid,
                command: "arguments"
              )
              client.set_up_in_business(command: "arguments")
            end
          end
        end

        describe "views" do
          specify ":registered_fishermen" do
            expect(client.registered_fishermen).to be == :registered_fishermen_records
          end

          specify ":fishing_grounds_available_to_join" do
            expect(client.fishing_grounds_available_to_join).to be == :fishing_grounds_available_to_join_records
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
          specify "go_to_fishing_ground" do
            expect {
              client.go_to_fishing_ground(:what_uuid?)
            }.to change { client.location_name }.to(:at_fishing_ground)
          end
        end
      end

      context "location: at_fishing_ground" do
        before(:each) do
          client.go_to_registrars_office
          poseidon.stub(sign_up_fisherman: :client_uuid)
          client.sign_up_fisherman(:unused_arguments)
          client.go_to_fishing_ground(:this_fishing_ground_uuid)
        end

        its(:location_details) {
          should be == { fishing_ground_uuid: :this_fishing_ground_uuid }
        }

        describe "client-specific commands" do
          specify "#start_fishing" do
            poseidon.should_receive(:start_fishing).with(uuid: :this_fishing_ground_uuid)
            client.start_fishing
          end

          specify "#end_current_year" do
            poseidon.should_receive(:end_year_in_fishing_ground).with(uuid: :this_fishing_ground_uuid)
            client.end_current_year
          end

          specify "#send_boat_out_to_sea" do
            poseidon.should_receive(:send_boat_out_to_sea).with(
              fishing_ground_uuid:    :this_fishing_ground_uuid,
              fishing_business_uuid:  :client_uuid,
              order:                  5
            )
            client.send_boat_out_to_sea(order: 5)
          end
        end

        describe "views" do
          specify ":fishing_ground_businesses" do
            # TODO: pass an argument hash to #records_for ?
            fishing_ground_businesses.should_receive(:records_for).
              with(:this_fishing_ground_uuid).
              and_return(:filtered_fishing_ground_businesses)

            expect(client.fishing_ground_businesses).to be == :filtered_fishing_ground_businesses
          end

          specify ":business_statistics" do
            business_statistics.should_receive(:record_for).
              with(
                fishing_ground_uuid: :this_fishing_ground_uuid,
                fishing_business_uuid: :client_uuid,
              ).and_return(:single_business_statistics_row)

            expect(client.business_statistics).to be == :single_business_statistics_row
          end
        end

        describe "movement" do
          # We will also need to know what happens when this isn't a valid
          # fishing ground, and when it's valid but isn't allowed at this point
          # for whatever reasons
          specify "go_to_registrars_office" do
            expect {
              client.go_to_registrars_office
            }.to change { client.location_name }.to(:inside_registrars_office)
          end
        end
      end

      describe "#poseidon" do
        it "delegates to the app" do
          expect(client.poseidon).to be poseidon
        end
      end

      describe "#read_models" do
        it "delegates to the app" do
          expect(client.read_models).to be read_models
        end
      end
    end
  end
end