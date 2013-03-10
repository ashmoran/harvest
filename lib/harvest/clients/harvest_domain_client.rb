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
          def_delegators :poseidon,
            :sign_up_fisherman, :open_fishing_ground

          def registered_fishermen
            read_models[:registered_fishermen].records
          end
        end
      end

      # Legacy interface

      def poseidon
        @app.poseidon
      end

      def read_models
        @app.read_models
      end
    end
  end
end