module Harvest; module Domain; class FishingGround; end; end; end
require_relative 'fishing_ground/order_fulfilment_policies'

module Harvest
  module Domain
    class FishingGround
      extend Realm::Domain::AggregateRoot

      Events.define(:fishing_ground_opened, :name, :starting_year, :lifetime, :starting_population, :carrying_capacity, :order_fulfilment)
      Events.define(:fishing_started)
      Events.define(:fishing_ended)
      Events.define(:fishing_ground_closed)
      Events.define(:new_fishing_business_opened, :fishing_business_uuid, :fishing_business_name)
      Events.define(:fishing_order_submitted, :fishing_business_uuid, :order)
      Events.define(:fishing_order_fulfilled, :fishing_business_uuid, :number_of_fish_caught)
      Events.define(:fishing_order_unfulfilled, :fishing_business_uuid, :number_of_fish_caught)
      Events.define(:year_advanced, :years_passed, :new_year)
      Events.define(:fish_regenerated, :number_of_fish_regenerated, :new_population)

      FishingOrderPolicies = {
        sequential: OrderFulfilmentPolicies::Sequential,
        random:     OrderFulfilmentPolicies::Random
      }

      def initialize(attributes)
        if !FishingOrderPolicies.has_key?(attributes[:order_fulfilment])
          raise Realm::Domain::ConstructionError.new(%'Unknown order fulfilment policy: "#{attributes[:order_fulfilment]}"')
        end

        fire(
          :fishing_ground_opened,
          uuid:                 Harvest.uuid,
          name:                 attributes[:name],
          starting_year:        attributes[:starting_year],
          lifetime:             attributes[:lifetime],
          starting_population:  attributes[:starting_population],
          carrying_capacity:    attributes[:carrying_capacity],
          order_fulfilment:     attributes[:order_fulfilment]
        )
      end

      def start_fishing
        fire(:fishing_started)
      end

      def close
        invalid_operation("FishingGround is already closed") unless @open
        fire(:fishing_ground_closed)
      end

      def new_fishing_business_opened(fishing_business, attributes)
        if @fishing_started
          invalid_operation("New businesses may not set up in a fishing ground once fishing has started")
        end

        fire(
          :new_fishing_business_opened,
          fishing_business_uuid: fishing_business.uuid,
          fishing_business_name: attributes[:fishing_business_name]
        )
      end

      def send_boat_out_to_sea(business_uuid, order)
        if !@fishing_started
          invalid_operation("Fishing must start before you can send a boat out to sea")
        end

        if !@fishing_business_uuids.include?(business_uuid)
          invalid_operation("Invalid FishingBusiness: #{business_uuid}")
        end

        fire(:fishing_order_submitted, fishing_business_uuid:  business_uuid, order: order)
      end

      def end_current_year
        assert_all_orders_submitted

        ordered_fishing_orders.each do |business_uuid, order_quantity|
          if order_quantity <= @fish_population
            fire(
              :fishing_order_fulfilled,
              fishing_business_uuid: business_uuid,
              number_of_fish_caught: order_quantity
            )
          else
            fire(
              :fishing_order_unfulfilled,
              fishing_business_uuid: business_uuid,
              number_of_fish_caught: 0
            )
          end
        end

        base_regenerated_fish = @fish_population
        new_population = [@fish_population + base_regenerated_fish, @carrying_capacity].min
        actual_regenerated_fish = new_population - @fish_population

        fire(
          :fish_regenerated,
          number_of_fish_regenerated: actual_regenerated_fish,
          new_population:             new_population
        )

        fire(:year_advanced, uuid: uuid, years_passed: 1, new_year: @current_year + 1)

        if @current_year == @starting_year + @lifetime
          fire(:fishing_ended)
          fire(:fishing_ground_closed)
        end
      end

      private

      def event_factory
        Events
      end

      # Event handlers

      def apply_fishing_ground_opened(event)
        @uuid                     = event.uuid
        @name                     = event.name
        @fishing_business_uuids   = [ ]
        @fishing_orders           = { }
        @open                     = true
        @fishing_started          = false
        @starting_year            = event.starting_year
        @lifetime                 = event.lifetime
        @current_year             = event.starting_year
        @fish_population          = event.starting_population
        @carrying_capacity        = event.carrying_capacity
        @order_fulfilment_policy  = FishingOrderPolicies.fetch(event.order_fulfilment)
      end

      def apply_fishing_started(event)
        @fishing_started = true
      end

      def apply_fishing_ended(event)
        # Currenly we close the fishing ground immediately after we end fishing
      end

      def apply_fishing_ground_closed(event)
        @open = false
      end

      def apply_new_fishing_business_opened(event)
        @fishing_business_uuids << event.fishing_business_uuid
      end

      def apply_fishing_order_submitted(event)
        @fishing_orders[event.fishing_business_uuid] = event.order
      end

      def apply_fishing_order_fulfilled(event)
        @fish_population -= event.number_of_fish_caught
      end

      def apply_fishing_order_unfulfilled(event)
        # We might never need to do anything in here...
        # but if we do we should watch out for partially fulfilled orders
      end

      def apply_year_advanced(event)
        @current_year += event.years_passed
      end

      def apply_fish_regenerated(event)
        @fish_population += event.number_of_fish_regenerated
      end

      # Private methods

      def assert_all_orders_submitted
        number_of_businesses  = @fishing_business_uuids.length
        number_of_orders      = @fishing_orders.length

        if number_of_orders < number_of_businesses
          invalid_operation(
            "Only #{number_of_orders} of #{number_of_businesses} businesses have submitted orders this year"
          )
        end
      end

      def ordered_fishing_orders
        @order_fulfilment_policy.wrap(@fishing_orders)
      end
    end
  end
end
