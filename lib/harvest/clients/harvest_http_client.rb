require 'frenetic'
require 'uuidtools'

# Something feels odd about reaching into a different module like this. The
# representations are effectively the (hypermedia) protocol to communicate
# with Harvest remotely.
require_relative '../http/representations'

module Harvest
  module Clients
    class HarvestHTTPClient
      def initialize(root_uri)
        @api = Frenetic.new(
          url: root_uri, headers: { accept: "application/hal+json" }
        )
      end

      def start
        move_to_root_resource
      end

      def reload
        move_to_resource(@current_resource.body.links[:self].href)
      end

      def location_name
        @current_resource.body[:location].to_sym
      end

      def location_details
        case location_name
        when :at_fishing_ground
          { fishing_ground_uuid: @fishing_ground_uuid }
        end
      end

      def inspect
        "<HarvestHTTPClient location=#{location_name.inspect}>"
      end

      def go_to_registrars_office
        return if location_name == :inside_registrars_office # Or reload?
        registrar_link = @current_resource.body.links[:"fisherman-registrar"].href
        move_to_resource(registrar_link)
      end

      # Valid at location :inside_registrars_office and currently :at_fishing_ground,
      # due to the Cucumber steps being easier to write(?) if this is idempotent
      def go_to_fishing_ground(fishing_ground_uuid)
        return if location_name == :at_fishing_ground # Or reload?

        # The rest heavily duplicated with other fishing ground methods
        fishing_grounds = @current_resource.body.resources[:"fishing-grounds-available-to-join"]

        # Isn't Frenetic supposed to do this for us???
        fishing_ground_link =
          fishing_grounds.detect { |ground|
            UUIDTools::UUID.parse(ground["uuid"]) == fishing_ground_uuid
          }["_links"]["self"]["href"]

        move_to_resource(fishing_ground_link)
        @fishing_ground_uuid = fishing_ground_uuid
      end

      # Valid at location :inside_registrars_office
      def sign_up_fisherman(command_attributes)
        registrar_link = @current_resource.body.links[:self].href
        application = HTTP::Representations::FishingApplication.new(command_attributes)
        response = @api.post(registrar_link, application.to_json, 'Content-Type' => 'application/json')

        # In here to satisfy Cucumber scenarios, don't know what to do about reloading yet
        reload

        @uuid = UUIDTools::UUID.parse(response.body["uuid"])
      end

      # Valid (bizarrely) at location :inside_registrars_office
      def open_fishing_ground(command_attributes)
        fishing_world_link = @current_resource.body.links[:"fishing-world"].href
        application = HTTP::Representations::FishingGroundApplication.new(command_attributes)
        response = @api.post(fishing_world_link, application.to_json, 'Content-Type' => 'application/json')

        # In here to satisfy Cucumber scenarios, don't know what to do about reloading yet
        reload

        UUIDTools::UUID.parse(response.body["uuid"])
      end

      # Valid (also bizarrely?) at location :inside_registrars_office
      def close_fishing_ground(command_attributes)
        @current_resource = @api.get(@current_resource.body.links[:self].href) # aka "reload"

        fishing_grounds = @current_resource.body.resources[:"fishing-grounds-available-to-join"]

        # Isn't Frenetic supposed to do this for us???
        fishing_ground_url =
          fishing_grounds.detect { |ground|
            UUIDTools::UUID.parse(ground["uuid"]) == command_attributes.fetch(:uuid)
          }["_links"]["self"]["href"]

        @api.delete(fishing_ground_url)
      end

      # Valid at location :inside_registrars_office
      def set_up_in_business(command_attributes)
        # Duplication with #close_fishing_ground
        @current_resource = @api.get(@current_resource.body.links[:self].href) # aka "reload"

        fishing_grounds = @current_resource.body.resources[:"fishing-grounds-available-to-join"]

        # Isn't Frenetic supposed to do this for us???
        fishing_ground_join_url =
          fishing_grounds.detect { |ground|
            UUIDTools::UUID.parse(ground["uuid"]) == command_attributes.fetch(:fishing_ground_uuid)
          }["_links"]["join"]["href"]

        application = HTTP::Representations::FishingBusinessApplication.new(
          fisherman_uuid: @uuid
        )

        # TODO: Send the right content type header!
        @api.post(fishing_ground_join_url, application.to_json, 'Content-Type' => 'application/json')
      end

      # Valid at location :at_fishing_ground
      def start_fishing
        @api.post(@current_resource.body.links["start_fishing"]["href"], "foo")
      end

      # Valid at location :at_fishing_ground
      def send_boat_out_to_sea(command_attributes)
        # Isn't Frenetic supposed to do this for us???
        fishing_order_uri = @current_resource.body.links["order"]["href"]

        order = HTTP::Representations::FishingOrder.new(
          fishing_business_uuid: @uuid,
          order: command_attributes[:order]
        )

        @api.post(fishing_order_uri, order.to_json, 'Content-Type' => 'application/json')
      end

      # Valid at location :at_fishing_ground
      # A HTTP client shouldn't be doing this!
      def end_current_year
        # Isn't Frenetic supposed to do this for us???
        year_end_uri = @current_resource.body.links["year_end"]["href"]

        @api.post(year_end_uri, nil)
      end

      # Valid at location :inside_registrars_office
      def registered_fishermen
        @current_resource.body.resources[:"registered-fishermen"].map(&:symbolize_keys)
      end

      # Valid at location :inside_registrars_office
      def fishing_grounds_available_to_join
        @current_resource.body.resources[:"fishing-grounds-available-to-join"].map(&:symbolize_keys)
      end

      # Valid at location :at_fishing_ground
      def fishing_ground_businesses
        @current_resource.body.resources[:"fishing-ground-businesses"].map(&:symbolize_keys)
      end

      # Valid at location :at_fishing_ground
      def business_statistics
        statistics_uri = @current_resource.body.links["statistics"]["href"]
        # TODO: State change?
        ground_statistics = @api.get(statistics_uri).body.resources["fishing-business-statistics"].
          map(&:symbolize_keys).
          map { |business| {
            fishing_ground_uuid:    UUIDTools::UUID.parse(business[:fishing_ground_uuid]),
            fishing_business_uuid:  UUIDTools::UUID.parse(business[:fishing_business_uuid]),
            lifetime_fish_caught:   business[:lifetime_fish_caught].to_i,
            # TODO: Decide if we care about losing currency information
            lifetime_profit:        business[:lifetime_profit]
          }
        }

        # Because we don't have any authorization yet...
        ground_statistics.detect { |statistics|
          statistics[:fishing_business_uuid] == @uuid
        }
      end

      # Legacy implementation

      def poseidon
        self
      end

      def read_models
        self
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

      def move_to_root_resource
        @current_resource = @api.get
      end

      def move_to_resource(uri)
        @current_resource = @api.get(uri)
        raise "Error loading resource #{@current_resource.inspect}" unless @current_resource.success?
      end

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