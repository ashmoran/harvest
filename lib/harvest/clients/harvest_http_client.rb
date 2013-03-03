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
        response = @api.post(registrar_link, application.to_json)
        UUIDTools::UUID.parse(response.body["uuid"])
      end

      def open_fishing_ground(command_attributes)
        fishing_world_link = @api.get.body.links[:"fishing-world"].href
        application = HTTP::Representations::FishingGroundApplication.new(command_attributes)
        UUIDTools::UUID.parse(@api.post(fishing_world_link, application.to_json).body["uuid"])
      end

      def close_fishing_ground(command_attributes)
        fishing_world_link = @api.get.body.links[:"fishing-world"].href
        fishing_grounds = @api.get(fishing_world_link).body.resources[:"fishing-grounds-available-to-join"]

        # Isn't Frenetic supposed to do this for us???
        fishing_ground_url =
          fishing_grounds.detect { |ground|
            UUIDTools::UUID.parse(ground["uuid"]) == command_attributes.fetch(:uuid)
          }["_links"]["self"]["href"]

        @api.delete(fishing_ground_url)
      end

      def set_fisherman_up_in_business(command_attributes)
        fishing_world_link = @api.get.body.links[:"fishing-world"].href
        fishing_grounds = @api.get(fishing_world_link).body.resources[:"fishing-grounds-available-to-join"]

        # Isn't Frenetic supposed to do this for us???
        fishing_ground_join_url =
          fishing_grounds.detect { |ground|
            UUIDTools::UUID.parse(ground["uuid"]) == command_attributes.fetch(:fishing_ground_uuid)
          }["_links"]["join"]["href"]

        application = HTTP::Representations::FishingBusinessApplication.new(
          fisherman_uuid: command_attributes[:fisherman_uuid]
        )

        @api.post(fishing_ground_join_url, application.to_json)
      end

      def start_fishing(command_attributes)
        # Doesn't actually do anything we care about yet
      end

      def [](read_model_name)
        case read_model_name
        when :registered_fishermen
          registrar_link = @api.get.body.links[:"fisherman-registrar"].href
          record_array(@api.get(registrar_link).body.resources[:"registered-fishermen"].map(&:symbolize_keys))
        when :fishing_grounds_available_to_join
          fishing_world_link = @api.get.body.links[:"fishing-world"].href
          view_model(
            EventHandlers::ReadModels::FishingGroundsAvailableToJoin,
            @api.get(fishing_world_link).
              body.
              resources[:"fishing-grounds-available-to-join"].
              map(&:symbolize_keys).
              map { |ground| ground.merge(uuid: UUIDTools::UUID.parse(ground[:uuid])) }
          )
        when :fishing_ground_businesses
          fishing_world_link = @api.get.body.links[:"fishing-world"].href
          fishing_grounds = @api.get(fishing_world_link).body.resources[:"fishing-grounds-available-to-join"]

          # The domain model code gets a read model back that contains all businesses for
          # all fishing grounds. The hypermedia UI currently segregates them into embedded
          # resources, so we join them back together to fake the read model view. Nasty,
          # but it gets us going.
          businesses = fishing_grounds.map { |fishing_ground|
            fishing_ground["_embedded"]["fishing-ground-businesses"]
          }.flatten

          view_model(
            EventHandlers::ReadModels::FishingGroundBusinesses,
            # WTF
            businesses.map(&:symbolize_keys).map { |business|
              business.merge(
                uuid: UUIDTools::UUID.parse(business[:uuid]),
                fishing_business_uuid: UUIDTools::UUID.parse(business[:fishing_business_uuid])
              )
            }
          )
        when :fishing_business_statistics
          # We're duplicating this logic everywhere
          fishing_world_link = @api.get.body.links[:"fishing-world"].href
          fishing_grounds = @api.get(fishing_world_link).body.resources[:"fishing-grounds-available-to-join"]

          # Same problem as :fishing_ground_businesses - we make a request per fishing ground!
          businesses = fishing_grounds.map { |fishing_ground|
            statistics_link = fishing_ground["_links"]["statistics"]["href"]
            @api.get(statistics_link).body.resources["fishing-business-statistics"]
          }.flatten

          # Holy shit
          records =
            businesses.map(&:symbolize_keys).map { |business|
              {
                fishing_ground_uuid:    UUIDTools::UUID.parse(business[:fishing_ground_uuid]),
                fishing_business_uuid:  UUIDTools::UUID.parse(business[:fishing_business_uuid]),
                lifetime_fish_caught:   business[:lifetime_fish_caught].to_i,
                lifetime_profit:        Harvest::Domain::Currency.dollar(business[:lifetime_profit].sub(/^\$/, "").to_i)
              }
            }

          view_model(
            EventHandlers::ReadModels::FishingBusinessStatistics,
            records
          )
        else
          raise "Unimplemented HTTP read model!"
        end
      end

      private

      # Fake the interface the Cucumber steps currently require
      def record_array(array)
        def array.records
          self
        end
        array
      end

      # Fake the interface the Cucumber steps currently require
      def view_model(model_class, records)
        database = InMemoryReadModelDatabase.new
        records.each do |record|
          database.save(record)
        end
        model_class.new(database)
      end
    end
  end
end