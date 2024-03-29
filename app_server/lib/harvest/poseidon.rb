require_relative 'domain'

module Harvest
  class Poseidon
    def initialize(command_bus: r(:command_bus), repositories: r(:repositories))
      @command_bus = command_bus

      @fishing_world        = repositories[:fishing_world]
      @fisherman_registrar  = repositories[:fisherman_registrar]
    end

    def sign_up_fisherman(command_attributes)
      @command_bus.send(
        Domain::Commands.build(:sign_up_fisherman, command_attributes)
      )
    end

    def open_fishing_ground(command_attributes)
      fishing_ground = Domain::FishingGround.create(command_attributes)
      @fishing_world.save(fishing_ground)
      fishing_ground.uuid
    end

    def start_fishing(command_attributes)
      fishing_ground = @fishing_world.get_by_id(command_attributes[:uuid])
      fishing_ground.start_fishing
      @fishing_world.save(fishing_ground)
    end

    def close_fishing_ground(command_attributes)
      fishing_ground = @fishing_world.get_by_id(command_attributes[:uuid])
      fishing_ground.close
      @fishing_world.save(fishing_ground)
    end

    def send_boat_out_to_sea(command_attributes)
      fishing_ground = @fishing_world.get_by_id(command_attributes[:fishing_ground_uuid])

      fishing_ground.send_boat_out_to_sea(
        command_attributes[:fishing_business_uuid],
        command_attributes[:order]
      )

      @fishing_world.save(fishing_ground)
    end

    def end_year_in_fishing_ground(command_attributes)
      fishing_ground = @fishing_world.get_by_id(command_attributes[:uuid])
      fishing_ground.end_current_year
      @fishing_world.save(fishing_ground)
    end

    # Moved to the command handler
    # def sign_up_fisherman(command_attributes)
    # end

    def set_fisherman_up_in_business(command_attributes)
      fisherman = @fisherman_registrar.get_by_id(command_attributes[:fisherman_uuid])
      fishing_ground = @fishing_world.get_by_id(command_attributes[:fishing_ground_uuid])

      fisherman.set_up_in_business_in(fishing_ground)

      @fishing_world.update(fishing_ground)
      @fisherman_registrar.update(fisherman)
    end
  end
end
