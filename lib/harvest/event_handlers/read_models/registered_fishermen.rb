module Harvest
  module EventHandlers
    module ReadModels
      class RegisteredFishermen
        def initialize(database)
          @database = database
        end

        def handle_fisherman_registered(event)
          @database.save(uuid: event.uuid, name: event.name)
        end

        def count
          @database.count
        end

        def records
          @database.records
        end
      end
    end
  end
end
