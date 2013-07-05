module Harvest
  module EventHandlers
    module ReadModels
      class FishingGroundBusinesses
        def initialize(database)
          @database = database
        end

        def handle_new_fishing_business_opened(event)
          @database.save(
            uuid:                  event.uuid,
            fishing_business_uuid: event.fishing_business_uuid,
            fishing_business_name: event.fishing_business_name
          )
        end

        def count
          @database.count
        end

        def records
          @database.records
        end

        def records_for(uuid)
          records.select { |record| record[:uuid] == uuid }
        end
      end
    end
  end
end
