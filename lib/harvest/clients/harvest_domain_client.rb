require 'state_machine'
require 'forwardable'

module Harvest
  module Clients
    class HarvestDomainClient
      def initialize(app)
        @app = app
        super()
      end

      state_machine :location, initial: :outside_registrars_office do
        event :go_to_registrars_office do
          transition :outside_registrars_office => :inside_registrars_office
        end

        state :inside_registrars_office do
          extend Forwardable
          def_delegators :poseidon, :sign_up_fisherman
        end
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