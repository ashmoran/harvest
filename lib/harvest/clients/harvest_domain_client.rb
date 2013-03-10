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

        event :go_to_fishing_ground do
          transition :inside_registrars_office => :at_fishing_ground
        end

        state :inside_registrars_office do
          extend Forwardable

          # Simple delegated commands

          def_delegators :poseidon,
            :open_fishing_ground, :close_fishing_ground

          # Complex delegated commands

          def sign_up_fisherman(command_attributes)
            @uuid = poseidon.sign_up_fisherman(command_attributes)
          end

          def set_up_in_business(command_attributes)
            poseidon.set_fisherman_up_in_business(command_attributes.merge(fisherman_uuid: @uuid))
          end

          # Views

          def registered_fishermen
            read_models[:registered_fishermen].records
          end

          def fishing_grounds_available_to_join
            read_models[:fishing_grounds_available_to_join].records
          end
        end

        state :at_fishing_ground do
          def location_details
            { fishing_ground_uuid: @fishing_ground_uuid }
          end

          # Views

          def fishing_ground_businesses
            read_models[:fishing_ground_businesses].records_for(@fishing_ground_uuid)
          end
        end
      end

      # Movement

      def go_to_fishing_ground(uuid)
        # TODO: clear this when leaving?
        @fishing_ground_uuid = uuid
        # TODO: Probably should check this works or we could be trampling state!
        super
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