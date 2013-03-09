require 'spec_helper'

require 'harvest/clients/harvest_domain_client'

require 'harvest/app'
require 'harvest/poseidon'

module Harvest
  module Clients
    describe HarvestDomainClient do
      let(:poseidon) { mock(Harvest::Poseidon, sign_up_fisherman: nil) }

      let(:app) {
        mock(Harvest::App, poseidon: poseidon, read_models: :real_read_models)
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

        it "delegates to Poseidon" do
          client.sign_up_fisherman(command: "arguments")
        end
      end

      describe "#poseidon" do
        it "delegates to the app" do
          expect(client.poseidon).to be poseidon
        end
      end

      describe "#read_models" do
        it "delegates to the app" do
          expect(client.read_models).to be == :real_read_models
        end
      end
    end
  end
end