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
          transition :at_fishing_ground => :inside_registrars_office
        end

        # Movement
        # TODO: consider raising an error on invalid movement,
        # which may mean parameterising a #go_to method
        event :go_to_fishing_ground do
          transition :inside_registrars_office => :at_fishing_ground
        end

        before_transition any => :at_fishing_ground do |client, transition|
          # I'd rather not have a setter while the state machine lives in the client class
          client.instance_variable_set(:@fishing_ground_uuid, transition.args.first)
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

          # Commands

          def start_fishing
            poseidon.start_fishing(uuid: @fishing_ground_uuid)
          end

          def end_current_year
            poseidon.end_year_in_fishing_ground(uuid: @fishing_ground_uuid)
          end

          def send_boat_out_to_sea(command_attributes)
            poseidon.send_boat_out_to_sea(
              fishing_business_uuid: @uuid,
              fishing_ground_uuid: @fishing_ground_uuid,
              order: command_attributes[:order]
            )
          end

          # Views

          # TODO: rename to businesses
          def fishing_ground_businesses
            read_models[:fishing_ground_businesses].records_for(@fishing_ground_uuid)
          end

          def business_statistics
            read_models[:fishing_business_statistics].record_for(
              fishing_business_uuid: @uuid,
              fishing_ground_uuid: @fishing_ground_uuid
            )
          end
        end
      end

      def start
        # NOOP
      end

      def reload
        # NOOP
      end

      def inspect
        "<HarvestDomainClient location=#{location_name.inspect}>"
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