require 'spec_helper'
require 'json'
require 'webmachine'

require 'harvest/app'
require 'harvest/poseidon'
require 'harvest/http/representations'
require 'harvest/http/server/resources'
require 'harvest/http/server/resource_creator'

module Harvest
  module HTTP
    module Server
      module Resources
        describe FishermanRegistrarServerResource do
          let(:poseidon) { mock(Poseidon, sign_up_fisherman: nil) }
          let(:harvest_app) { mock(Harvest::App, poseidon: poseidon) }

          let(:base_uri) { "" }

          let(:resource_creator) {
            Harvest::HTTP::Server::ResourceCreator.new(
              harvest_app:  harvest_app,
              base_uri:     base_uri,
              cache_path:   :unused
            )
          }

          let(:dispatcher) {
            Webmachine::Dispatcher.new(resource_creator).tap do |dispatcher|
              dispatcher.add_route([ ], described_class)
            end
          }

          let(:request) {
            # real URI
            Webmachine::Request.new(
              "POST", URI::HTTP.build(path: "/"), Webmachine::Headers.new, request_body
            )
          }

          subject(:response) { Webmachine::TestResponse.build }

          before(:each) do
            dispatcher.dispatch(request, response)
          end

          context "malformed request JSON" do
            let(:request_body) { "{ this is not JSON" }

            its(:code) { should be == 400 }

            specify "body" do
              expect(JSON.parse(response.body)).to be == {
                "error"   => "malformed_request",
                "message" => "Request body contained malformed JSON"
              }
            end
          end

          context "valid request" do
            let(:request_body) { "{ 'todo': 'next' }" }

            it "does something" do
              pending
            end
          end
        end
      end
    end
  end
end
