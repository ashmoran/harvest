require 'frenetic'

# Something feels odd about reaching into a different module like this. The
# representations are effectively the (hypermedia) protocol to communicate
# with Harvest remotely.
require_relative '../http/representations'

module Harvest
  module Clients
    class HarvestHTTPClient
      def initialize(root_uri)
        @api = Frenetic.new(url: root_uri, headers: { accept: "application/hal+json" })
      end

      def poseidon
        self
      end

      def read_models
        self
      end

      def sign_up_fisherman(command_attributes)
        registrar_link = @api.get.body.links[:"fisherman-registrar"].href
        name = command_attributes.fetch(:name)
        application = HTTP::Representations::FishingApplication.new(name: name)
        @api.post(registrar_link, application.to_json)

        nil # id goes here
      end

      def open_fishing_ground(command_attributes)
        fishing_world_link = @api.get.body.links[:"fishing-world"].href
        application = HTTP::Representations::FishingGroundApplication.new(command_attributes)
        @api.post(fishing_world_link, application.to_json).body["uuid"]
      end

      def close_fishing_ground(command_attributes)
        fishing_world_link = @api.get.body.links[:"fishing-world"].href
        fishing_grounds = @api.get(fishing_world_link).body.resources[:"fishing-grounds-available-to-join"]

        # Isn't Frenetic supposed to do this for us???
        fishing_ground_url =
          fishing_grounds.detect { |ground|
            ground["uuid"] == command_attributes.fetch(:uuid)
          }["_links"]["self"]["href"]

        @api.delete(fishing_ground_url)
      end

      def [](read_model_name)
        case read_model_name
        when :registered_fishermen
          registrar_link = @api.get.body.links[:"fisherman-registrar"].href
          record_array(@api.get(registrar_link).body.resources[:"registered-fishermen"].map(&:symbolize_keys))
        when :fishing_grounds_available_to_join
          fishing_world_link = @api.get.body.links[:"fishing-world"].href
          view_model(@api.get(fishing_world_link).body.resources[:"fishing-grounds-available-to-join"].map(&:symbolize_keys))
        end
      end

      private

      def record_array(array)
        def array.records
          self
        end
        array
      end

      def view_model(records)
        database = InMemoryReadModelDatabase.new
        records.each do |record|
          database.save(record)
        end
        EventHandlers::ReadModels::FishingGroundsAvailableToJoin.new(database)
      end
    end
  end
end