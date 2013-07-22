module Harvest
  module Domain
    Events = Realm::Messaging::MessageFactory.new do |events|
      # Fisherman
      events.define(:fisherman_registered, :uuid, :name)
      events.define(:fisherman_set_up_in_business_in, :uuid, :fishing_ground_uuid)
      events.define(:user_assigned_to_fisherman, :uuid, :user_uuid)

      # FishingGround
      events.define(:fishing_ground_opened, :uuid, :name, :starting_year, :lifetime, :starting_population, :carrying_capacity, :order_fulfilment)
      events.define(:fishing_started, :uuid)
      events.define(:fishing_ended, :uuid)
      events.define(:fishing_ground_closed, :uuid)
      events.define(:new_fishing_business_opened, :uuid, :fishing_business_uuid, :fishing_business_name)
      events.define(:fishing_order_submitted, :uuid, :fishing_business_uuid, :order)
      events.define(:fishing_order_fulfilled, :uuid, :fishing_business_uuid, :number_of_fish_caught)
      events.define(:fishing_order_unfulfilled, :uuid, :fishing_business_uuid, :number_of_fish_caught)
      events.define(:year_advanced, :uuid, :years_passed, :new_year)
      events.define(:fish_regenerated, :uuid, :number_of_fish_regenerated, :new_population)
    end
  end
end
