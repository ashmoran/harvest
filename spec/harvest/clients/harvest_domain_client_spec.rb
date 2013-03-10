require 'spec_helper'

require 'harvest/clients/harvest_domain_client'

require 'harvest/app'
require 'harvest/poseidon'

module Harvest
  module Clients
    describe HarvestDomainClient do
      def mock_read_model(name)
        mock("Read Model :#{name}", records: :"#{name}_records")
      end

      let(:poseidon) { mock(Harvest::Poseidon, sign_up_fisherman: nil) }

      let(:read_models) {
        {
          registered_fishermen: mock_read_model("registered_fishermen"),
          fishing_grounds_available_to_join: mock_read_model("fishing_grounds_available_to_join")
        }
      }

      let(:app) {
        mock(Harvest::App, poseidon: poseidon, read_models: read_models)
      }
      subject(:client) { HarvestDomainClient.new(app) }

      context "new" do
        its(:location_name) { should be == :outside_registrars_office }
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
        end

        describe "view delegation" do
          specify ":registered_fishermen" do
            expect(client.registered_fishermen).to be == :registered_fishermen_records
          end

          specify ":fishing_grounds_available_to_join" do
            expect(client.fishing_grounds_available_to_join).to be == :fishing_grounds_available_to_join_records
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