module Harvest
  module Domain
    Events = Realm::Messaging::MessageFactory.new do |events|
      # Fisherman
      events.define(:fisherman_registered,
        properties: {
          uuid: UUIDTools::UUID,
          name: String
        }
      )
      events.define(:fisherman_set_up_in_business_in,
        properties: {
          uuid: UUIDTools::UUID,
          fishing_ground_uuid: UUIDTools::UUID,
        }
      )
      events.define(:user_assigned_to_fisherman,
        properties: {
          uuid: UUIDTools::UUID,
          user_uuid: UUIDTools::UUID,
        }
      )

      # FishingGround
      events.define(:fishing_ground_opened,
        properties: {
          uuid:                 UUIDTools::UUID,
          name:                 String,
          starting_year:        Integer,
          lifetime:             Integer,
          starting_population:  Integer,
          carrying_capacity:    Integer,
          order_fulfilment:     Symbol
        }
      )
      events.define(:fishing_started,
        properties: {
          uuid: UUIDTools::UUID,
        }
      )
      events.define(:fishing_ended,
        properties: {
          uuid: UUIDTools::UUID,
        }
      )
      events.define(:fishing_ground_closed,
        properties: {
          uuid: UUIDTools::UUID,
        }
      )
      events.define(:new_fishing_business_opened,
        properties: {
          uuid:                   UUIDTools::UUID,
          fishing_business_uuid:  UUIDTools::UUID,
          fishing_business_name:  String
        }
      )
      events.define(:fishing_order_submitted,
        properties: {
          uuid:                   UUIDTools::UUID,
          fishing_business_uuid:  UUIDTools::UUID,
          order:                  Integer
        }
      )
      events.define(:fishing_order_fulfilled,
        properties: {
          uuid:                   UUIDTools::UUID,
          fishing_business_uuid:  UUIDTools::UUID,
          number_of_fish_caught:  Integer
        }
      )
      events.define(:fishing_order_unfulfilled,
        properties: {
          uuid:                   UUIDTools::UUID,
          fishing_business_uuid:  UUIDTools::UUID,
          number_of_fish_caught:  Integer
        }
      )
      events.define(:year_advanced,
        properties: {
          uuid:           UUIDTools::UUID,
          years_passed:   Integer,
          new_year:       Integer
        }
      )
      events.define(:fish_regenerated,
        properties: {
          uuid:                       UUIDTools::UUID,
          number_of_fish_regenerated: Integer,
          new_population:             Integer
        }
      )
    end
  end
end
