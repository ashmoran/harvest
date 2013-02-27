module Harvest
  module EventHandlers
    module ReadModels
      class FishingGroundsAvailableToJoin
      	def initialize(database)
      		@database = database
      	end

      	def handle_fishing_ground_opened(event)
      		@database.save(
            uuid:           event.uuid,
            name:           event.name,
            starting_year:  event.starting_year,
            current_year:   event.starting_year
          )
      	end

        def handle_year_advanced(event)
          record = record_for(uuid: event.uuid)
          @database.update([ :uuid ], record.merge(current_year: event.new_year))
        end

      	def handle_fishing_ground_closed(event)
      		@database.delete(uuid: event.uuid)
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
      end
    end
  end
end
