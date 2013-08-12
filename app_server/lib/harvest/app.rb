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
      read_model_databases.each do |model_name, database|
        database.reset
      end
    end

    def command_bus
      message_bus
    end

    def application_services
      @application_services ||= Hash.new
    end

    def read_models
      @read_models ||= Hash.new
    end

    private

    def boot
      load_subsystems
      connect_command_handlers
      connect_read_models
      connect_application_services
      connect_message_logger
    end

    def load_subsystems
      @id_access = Realm::Systems::IdAccess::App.new(
        message_bus:    message_bus,
        event_store:    event_store,
        query_database: read_model_databases, # Hack! Just so internally we get dbs[:table_name]
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

    def connect_command_handlers
      message_bus.register(
        :sign_up_fisherman,
        Harvest::Application::CommandHandlers::SignUpFisherman.new(
          command_bus:          message_bus,
          fisherman_registrar:  fisherman_registrar
        )
      )
    end

    def connect_read_models
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

    def connect_read_model(name, options)
      read_models[name] =
        options[:read_model_class].new(read_model_databases[name])

      options[:events].each do |event_name|
        message_bus.register(event_name, read_models[name])
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

    def read_model_databases
      @read_model_databases ||= Hash.new { |hash, key| hash[key] = InMemoryReadModelDatabase.new }
    end

    def fisherman_registrar
      @fisherman_registrar ||= Domain::FishermanRegistrar.new(event_store)
    end

    def message_bus
      @message_bus ||= Realm::Messaging::Bus::SimpleMessageBus.new
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
  end
end