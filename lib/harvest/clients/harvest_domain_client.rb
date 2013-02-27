module Harvest
  module Clients
    class HarvestDomainClient
      def initialize(app)
        @app = app
      end

      def poseidon
        @app.poseidon
      end

      def read_models
        @app.read_models
      end
    end
  end
end