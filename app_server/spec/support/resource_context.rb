require 'json'
require 'webmachine'

require 'harvest/app'
require 'harvest/http/server/resource_creator'

shared_context "resource context", type: :resource do
  let(:command_bus) { double(Realm::Messaging::Bus::MessageBus, send: nil) }

  let(:harvest_app) {
    double(Harvest::App,
      command_bus: command_bus,
      application_services: Hash.new
    )
  }

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
      dispatcher.add_route(resource_route, described_class)
    end
  }

  let(:request) {
    Webmachine::Request.new(
      request_method, URI::HTTP.build(path: request_path), Webmachine::Headers.new, request_body
    )
  }

  subject(:response) { Webmachine::TestResponse.build }


  def dispatch_request
    dispatcher.dispatch(request, response)
  end
end