module Harvest
  module Domain
    class Fisherman
      extend CQEDomain::Domain::AggregateRoot

      Events.define(:fisherman_registered, :name)
      Events.define(:fisherman_set_up_in_business_in, :fishing_ground_uuid)

      def initialize(attributes)
        fire(:fisherman_registered, uuid: Harvest.uuid, name: attributes[:name])
      end

      def set_up_in_business_in(fishing_ground)
        invalid_operation("Fisherman is already in business there") if @current_fishing_ground_uuid

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

      def apply_fisherman_set_up_in_business_in(event)
        @current_fishing_ground_uuid = event.fishing_ground_uuid
      end
    end
  end
end
