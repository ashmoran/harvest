require 'spec_helper'

require 'harvest'
require 'harvest/http/server'
require 'harvest/clients/harvest_http_client'

describe "POST fishing application (sign up fisherman)", allow_net_connect: true do
  let(:app) { Harvest::App.new }

  let(:port) { 3300 }
  let(:server) {
    Harvest::HTTP::Server::HarvestHTTPServer.new(
      harvest_app:  app,
      port:         port,
      cache_path:   File.expand_path(PROJECT_DIR + "/tmp/cache/#{port}")
    )
  }

  let(:client) { Harvest::Clients::HarvestHTTPClient.new("http://localhost:#{port}/api") }

  before(:each) { server.start }
  before(:each) { client.start }
  after(:each)  { server.stop }

  context "valid application" do
    it "returns a UUID" do
      client.go_to_registrars_office
      result = client.sign_up_fisherman(
        username:       "username",
        email_address:  "unimportant@example.com",
        password:       "password"
      )
      expect(result).to be_a(UUIDTools::UUID)
    end
  end

  context "invalid username" do
    it "returns an error" do
      client.go_to_registrars_office
      expect {
        client.sign_up_fisherman(
          username:       "invalid username!",
          email_address:  "unimportant@example.com",
          password:       "password"
        )
      }.to raise_error(RuntimeError, /command_failed_validation:.*Invalid username/)
    end
  end
end