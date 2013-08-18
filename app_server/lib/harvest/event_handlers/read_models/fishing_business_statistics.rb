module Harvest
  module EventHandlers
    module ReadModels
      class FishingBusinessStatistics
        include Celluloid

        MAGIC_NUMBER_PROFIT_PER_FISH = 5

        def initialize(database)
          @database = database
        end

        def handle_new_fishing_business_opened(event)
          @database.save(
            fishing_ground_uuid:    event.uuid,
            fishing_business_uuid:  event.fishing_business_uuid,
            lifetime_fish_caught:   0,
            lifetime_profit:        Harvest::Domain::Currency.dollar(0)
          )
        end

        def handle_fishing_order_fulfilled(event)
          record = record_for_fishing_order_fulfilled_event(event)

          record[:lifetime_fish_caught] += event.number_of_fish_caught
          record[:lifetime_profit] +=
            Harvest::Domain::Currency.dollar(event.number_of_fish_caught * MAGIC_NUMBER_PROFIT_PER_FISH)

          @database.update([ :fishing_ground_uuid, :fishing_business_uuid ], record)
        end

        def count
          @database.count
        end

        def records
          @database.records
        end

        def record_for(query)
          records.detect { |record|
            query.all? { |field, value| record[field] == value }
          }
        end

        def records_for(query)
          records.select { |record|
            query.all? { |field, value| record[field] == value }
          }
        end

        private

        def record_for_fishing_order_fulfilled_event(event)
          record_for(
            fishing_ground_uuid:    event.uuid,
            fishing_business_uuid:  event.fishing_business_uuid
          )
        end
      end
    end
  end
end