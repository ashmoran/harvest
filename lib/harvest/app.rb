module Harvest
  class App
    def initialize
      boot
    end

    # Hack for Cucumber
    def reset
      event_store.reset
      read_model_databases.each do |model_name, database|
        database.reset
      end
    end

    def poseidon
      @poseidon ||=
        Harvest::Poseidon.new(
          fishing_world:        Domain::FishingWorld.new(event_store),
          fisherman_registrar:  Domain::FishermanRegistrar.new(event_store)
        )
    end

    def read_models
      @read_models ||= Hash.new
    end

    private

    def boot
      connect_read_model(
        :registered_fishermen,
        read_model_class: Harvest::EventHandlers::ReadModels::RegisteredFishermen,
        events: [ :fisherman_registered ]
      )

      connect_read_model(
        :fishing_grounds_available_to_join,
        read_model_class: Harvest::EventHandlers::ReadModels::FishingGroundsAvailableToJoin,
        events: [ :fishing_ground_opened, :year_advanced, :fishing_ground_closed ]
      )

      connect_read_model(
        :fishing_ground_businesses,
        read_model_class: Harvest::EventHandlers::ReadModels::FishingGroundBusinesses,
        events: [ :new_fishing_business_opened ]
      )

      connect_read_model(
        :fishing_business_statistics,
        read_model_class: Harvest::EventHandlers::ReadModels::FishingBusinessStatistics,
        events: [ :new_fishing_business_opened, :fishing_order_fulfilled ]
      )
    end

    def connect_read_model(name, options)
      read_models[name] =
        options[:read_model_class].new(read_model_databases[name])

      options[:events].each do |event_name|
        event_bus.register(event_name, read_models[name])
      end
    end

    def read_model_databases
      @read_model_databases ||= Hash.new { |hash, key| hash[key] = InMemoryReadModelDatabase.new }
    end

    def event_bus
      @event_bus ||= CQEDomain::Bus::SimpleEventBus.new
    end

    def event_store
      @event_store ||= CQEDomain::EventStore::InMemoryEventStore.new(event_bus)
    end
  end
end