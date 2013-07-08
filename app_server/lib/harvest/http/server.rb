require 'celluloid/autostart'
require 'webmachine'
require 'webmachine/adapters/reel'
require 'webmachine/trace'

require 'ap' # Because, for now, this is better than dying with a 500

require_relative 'reel_adapter_monkeypatch'
require_relative 'webmachine_trace_to_json_monkeypatch'

module Harvest; module HTTP; module Server; end; end; end

require_relative 'representations'
require_relative 'server/resource'
require_relative 'server/resources'
require_relative 'server/resource_creator'

Celluloid.logger.level = Logger::DEBUG

module Harvest
  module HTTP
    module Server
      class HarvestHTTPServer
        def initialize(port: 3000, harvest_app: nil, cache_path: nil)
          raise "No harvest_app provided" if harvest_app.nil?
          base_uri = "http://localhost:#{port}"

          @app = build_app(
            harvest_app:  harvest_app,
            port:         port,
            base_uri:     base_uri,
            cache_path:   cache_path
          )
        end

        def start
          @server = @app.run
        end

        def stop
          @server.terminate
        end

        private

        def build_app(harvest_app: nil, base_uri: nil, port: nil, cache_path: nil)
          resource_creator = ResourceCreator.new(
            harvest_app:  harvest_app,
            base_uri:     base_uri,
            cache_path:   cache_path
          )

          dispatcher = Webmachine::Dispatcher.new(resource_creator)

          Webmachine::Application.new(Webmachine::Configuration.default, dispatcher) do |app|
            app.configure do |config|
              config.port = port
              config.adapter = :Reel
            end

            app.routes do
              add ['trace', '*'],                                 Webmachine::Trace::TraceResource

              add ['api'],                                        Resources::HarvestServerResource
              add ['api', 'fisherman-registrar'],                 Resources::FishermanRegistrarServerResource
              add ['api', 'fishing-world'],                       Resources::FishingWorldServerResource
              add ['api', 'fishing-ground', :uuid, 'statistics'], Resources::FishingBusinessStatisticsServerResource
              add ['api', 'fishing-ground', '*'],                 Resources::FishingGroundServerResource

              # TODO: Run these separately - they don't need the Harvest app
              [
                ['play'],
                ['signup'],
                [ ]
              ].each do |path_tokens|
                add path_tokens, Resources::WebAppAsset
              end

              # TODO: serve CoffeScript as compiled JS files instead (like below)
              add ['lib', 'harvest', '*'],    Resources::CoffeeScriptFileResource
              add ['lib', '*'],               Resources::JavaScriptFileResource
              add ['styles', '*'],            Resources::SassFileResource
              add ['fonts', '*'],             Resources::FontFileResource

              add ['*'], Resources::RouteDebugServerResource
            end
          end
        end
      end
    end
  end
end