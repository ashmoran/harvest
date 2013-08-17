require 'realm/systems/id_access'

module Harvest
  class App
    def initialize(components = { })
      @message_logger = components[:message_logger]
      boot
    end

    # Hack for Cucumber
    def reset
      event_store.reset
      query_database.each do |model_name, database|
        database.reset
      end
    end

    def command_bus
      message_bus
    end

    def application_services
      @application_services ||= Hash.new
    end

    def query_models
      @query_models ||= Hash.new
    end

    # Temporary hack so I don't have to rename read_models everywhere yet
    alias_method :read_models, :query_models

    private

    def boot
      load_subsystems
      configure_subsystem_message_routing
      connect_command_handlers
      connect_query_models
      connect_application_services
      connect_message_logger
    end

    def load_subsystems
      @id_access = Realm::Systems::IdAccess::App.new(
        message_bus:    id_access_message_bus,
        message_logger: message_logger,
        event_store:    id_access_event_store, # We need an event store wired up to the right bus
        query_database: query_database, # Hack! Just so internally we get dbs[:table_name]
        cryptographer:  Realm::Systems::IdAccess::Services::AlKindi.new,
        config: {
          commands: {
            # While it's nice to have the flexibility to define the validation here
            # to suit our own needs, it's a shame we can't easily test "user validation"
            sign_up_user: {
              validator: Realm::Domain::Validation::CommandValidator.new(
                validators: {
                  username:
                    Realm::Domain::Validation::RegexValidator.new(/^\w{1,16}$/),
                  email_address:
                    Realm::Domain::Validation::EmailValidator.new
                },
                messages: {
                  username:       "Username is invalid",
                  email_address:  "Email address is invalid"
                }
              )
            }
          }
        }
      ).boot
    end

    def configure_subsystem_message_routing
      message_bus.route_messages_for_subsystem(:id_access, to_message_bus: id_access_message_bus)
    end

    def connect_command_handlers
      message_bus.register(
        :sign_up_fisherman,
        Harvest::Application::CommandHandlers::SignUpFisherman.new(
          command_bus:          message_bus,
          fisherman_registrar:  fisherman_registrar
        )
      )
    end

    def connect_query_models
      connect_query_model(
        :registered_fishermen,
        query_model_class: Harvest::EventHandlers::ReadModels::RegisteredFishermen,
        events: [ :fisherman_registered ]
      )

      connect_query_model(
        :fishing_grounds_available_to_join,
        query_model_class: Harvest::EventHandlers::ReadModels::FishingGroundsAvailableToJoin,
        events: [ :fishing_ground_opened, :year_advanced, :fishing_ground_closed ]
      )

      connect_query_model(
        :fishing_ground_businesses,
        query_model_class: Harvest::EventHandlers::ReadModels::FishingGroundBusinesses,
        events: [ :new_fishing_business_opened ]
      )

      connect_query_model(
        :fishing_business_statistics,
        query_model_class: Harvest::EventHandlers::ReadModels::FishingBusinessStatistics,
        events: [ :new_fishing_business_opened, :fishing_order_fulfilled ]
      )
    end

    def connect_application_services
      # This is really hacky, we're exposing a domain service from
      # Realm::Systems::IdAccess as an application service here
      # (actually it might be an application service, but it needs moving,
      # see the Realm source for notes)
      application_services[:user_service] = @id_access.application_services[:user_service]

      # Not sure if this is temporary or if we'll refactor everything to use this:
      application_services[:poseidon] = poseidon
    end

    def connect_message_logger
      message_bus.register(:all_messages, message_logger)
    end

    def connect_query_model(name, query_model_class: r(:query_model_class), events: r(:events))
      query_models[name] =
        query_model_class.new(@query_database[name])

      events.each do |event_name|
        @message_bus.register(event_name, query_models[name])
      end
    end

    # Eventually we'll move everything to command handlers and then we
    # might be able to do away with this, unless it becomes a thin adapter
    # to the command bus
    # Now private: use `application_services[:poseidon]` instead
    def poseidon
      @poseidon ||=
        Harvest::Poseidon.new(
          command_bus: command_bus,
          repositories: {
            fishing_world:        Domain::FishingWorld.new(event_store),
            fisherman_registrar:  Domain::FishermanRegistrar.new(event_store)
          }
        )
    end

    def query_database
      @query_database ||= Hash.new { |hash, key| hash[key] = InMemoryReadModelDatabase.new }
    end

    def fisherman_registrar
      @fisherman_registrar ||= Domain::FishermanRegistrar.new(event_store)
    end

    def message_bus
      @message_bus ||=
        new_message_bus(
          new_result_factory(
            commands:   Domain::Commands,
            responses:  Domain::Responses
          )
        )
    end

    def id_access_message_bus
      @id_access_message_bus ||=
        new_message_bus(
          new_result_factory(
            commands:   Realm::Systems::IdAccess::Application::Commands,
            responses:  Realm::Systems::IdAccess::Application::Responses
          )
        )
    end

    def new_message_bus(result_factory)
      Realm::Messaging::Bus::SimpleMessageBus.new(result_factory: result_factory)
    end

    def new_result_factory(messages)
      Realm::Messaging::ResultFactory.new(messages)
    end

    def message_logger
      @message_logger ||=
        Realm::Messaging::Handlers::MessageLogger.new(
          format_with:  Realm::Messaging::Formatting::PrettyTerminalMessageFormatter.new,
          log_to:       Logger.new(STDOUT)
        )
    end

    def event_store
      @event_store ||= Realm::EventStore::InMemoryEventStore.new(message_bus)
    end

    def id_access_event_store
      @id_access_event_store ||= Realm::EventStore::InMemoryEventStore.new(id_access_message_bus)
    end
  end
end