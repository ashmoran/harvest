require 'spec_helper'

require 'harvest/clients/harvest_domain_client'
require 'harvest/app'

module Harvest
  module Clients
    describe HarvestDomainClient do
      let(:app) {
        mock(Harvest::App, poseidon: :real_neptune, read_models: :real_read_models)
      }
      subject(:client) { HarvestDomainClient.new(app) }

      describe "#poseidon" do
        it "delegates to the app" do
          expect(client.poseidon).to be == :real_neptune
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