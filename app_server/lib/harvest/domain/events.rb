module Harvest
  module Domain
    Events = Realm::Messaging::MessageFactory.new do |events|
      # Fisherman
      events.define(:fisherman_registered, :name)
      events.define(:fisherman_set_up_in_business_in, :fishing_ground_uuid)

      # FishingGround
      events.define(:fishing_ground_opened, :name, :starting_year, :lifetime, :starting_population, :carrying_capacity, :order_fulfilment)
      events.define(:fishing_started)
      events.define(:fishing_ended)
      events.define(:fishing_ground_closed)
      events.define(:new_fishing_business_opened, :fishing_business_uuid, :fishing_business_name)
      events.define(:fishing_order_submitted, :fishing_business_uuid, :order)
      events.define(:fishing_order_fulfilled, :fishing_business_uuid, :number_of_fish_caught)
      events.define(:fishing_order_unfulfilled, :fishing_business_uuid, :number_of_fish_caught)
      events.define(:year_advanced, :years_passed, :new_year)
      events.define(:fish_regenerated, :number_of_fish_regenerated, :new_population)
    end
  end
end
