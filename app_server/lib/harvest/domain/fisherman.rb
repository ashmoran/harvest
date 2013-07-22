module Harvest
  module Domain
    class Fisherman
      extend Realm::Domain::AggregateRoot

      def initialize(attributes)
        fire(:fisherman_registered, uuid: Harvest.uuid, name: attributes[:name])
      end

      def assign_user(uuid: required(:uuid))
        fire(:user_assigned_to_fisherman, user_uuid: uuid)
      end

      def set_up_in_business_in(fishing_ground)
        invalid_operation("Fisherman is already in business there") if @current_fishing_ground_uuid

        # Command calling command - this is the clue we need a long running process for the ground
        # (by comparison, assign_user above only takes the uuid)
        fishing_ground.new_fishing_business_opened(self, fishing_business_name: @name)

        fire(:fisherman_set_up_in_business_in, uuid: uuid, fishing_ground_uuid: fishing_ground.uuid)
      end

      private

      def event_factory
        Events
      end

      def apply_fisherman_registered(event)
        @uuid = event.uuid
        @name = event.name
        @current_fishing_ground_uuid = nil
      end

      def apply_user_assigned_to_fisherman(event)
        # Currently unused:
        # @user_uuid = event.user_uuid
      end

      def apply_fisherman_set_up_in_business_in(event)
        @current_fishing_ground_uuid = event.fishing_ground_uuid
      end
    end
  end
end
