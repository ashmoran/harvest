require 'spec_helper'

require 'harvest/poseidon'

module Harvest
  describe Poseidon do
    let(:fishing_ground) {
      double(
        Domain::FishingGround,
        uuid:                 :aggregate_root_uuid,
        start_fishing:        nil,
        close:                nil,
        end_current_year:     nil,
        send_boat_out_to_sea: nil
      )
    }
    let(:fishing_world) {
      double(Domain::FishingWorld, save: nil, get_by_id: fishing_ground, update: nil)
    }

    let(:fisherman) { double(Domain::Fisherman, uuid: :aggregate_root_uuid, set_up_in_business_in: nil) }
    let(:fisherman_registrar) {
      double(Domain::FishermanRegistrar, register: nil, get_by_id: fisherman, update: nil)
    }

    subject(:poseidon) {
      Poseidon.new(
        fishing_world:        fishing_world,
        fisherman_registrar:  fisherman_registrar
      )
    }

    describe "FishingGround commands" do
      before(:each) do
        Domain::FishingGround.stub(create: fishing_ground)
      end

      describe "#open_fishing_ground" do
        def open_fishing_ground
          poseidon.open_fishing_ground(
            uuid:                 :aggregate_root_uuid,
            name:                 "New fishing ground name",
            starting_year:        2012,
            lifetime:             10,
            starting_population:  40,
            carrying_capacity:    40
          )
        end

        it "makes a FishingGround" do
          Domain::FishingGround.should_receive(:create).with(
            uuid:                 :aggregate_root_uuid,
            name:                 "New fishing ground name",
            starting_year:        2012,
            lifetime:             10,
            starting_population:  40,
            carrying_capacity:    40
          )

          open_fishing_ground
        end

        it "saves the FishingGround" do
          fishing_world.should_receive(:save).with(fishing_ground)
          open_fishing_ground
        end

        it "returns the FishingGround's UUID" do
          expect(open_fishing_ground).to be == :aggregate_root_uuid
        end
      end

      describe "#start_fishing" do
        def start_fishing
          poseidon.start_fishing(uuid: :aggregate_root_uuid)
        end

        it "finds the FishingGround" do
          fishing_world.should_receive(:get_by_id).with(:aggregate_root_uuid)
          start_fishing
        end

        it "starts fishing" do
          fishing_ground.should_receive(:start_fishing)
          start_fishing
        end

        it "saves the FishingGround" do
          fishing_world.should_receive(:save).with(fishing_ground)
          start_fishing
        end
      end

      describe "#close_fishing_ground" do
        def close_fishing_ground
          poseidon.close_fishing_ground(uuid: :aggregate_root_uuid)
        end

        it "finds the FishingGround" do
          fishing_world.should_receive(:get_by_id).with(:aggregate_root_uuid)
          close_fishing_ground
        end

        it "closes the FishingGround" do
          fishing_ground.should_receive(:close)
          close_fishing_ground
        end

        it "saves the FishingGround" do
          fishing_world.should_receive(:save).with(fishing_ground)
          close_fishing_ground
        end
      end

      describe "#end_year_in_fishing_ground" do
        def end_year_in_fishing_ground
          poseidon.end_year_in_fishing_ground(uuid: :aggregate_root_uuid)
        end

        it "finds the FishingGround" do
          fishing_world.should_receive(:get_by_id).with(:aggregate_root_uuid)
          end_year_in_fishing_ground
        end

        it "ends the current year" do
          fishing_ground.should_receive(:end_current_year)
          end_year_in_fishing_ground
        end

        it "saves the FishingGround" do
          fishing_world.should_receive(:save).with(fishing_ground)
          end_year_in_fishing_ground
        end
      end
    end

    describe "Fisherman commands" do
      before(:each) do
        Domain::Fisherman.stub(create: fisherman)
      end

      describe "#sign_up_fisherman" do
        def sign_up_fisherman
          poseidon.sign_up_fisherman(
            uuid: :aggregate_root_uuid,
            name: "Fisherman Ahab"
          )
        end

        it "makes a Fisherman" do
          Domain::Fisherman.should_receive(:create).with(
            uuid: :aggregate_root_uuid,
            name: "Fisherman Ahab"
          )

          sign_up_fisherman
        end

        it "saves the Fisherman" do
          fisherman_registrar.should_receive(:register).with(fisherman)
          sign_up_fisherman
        end

        it "returns the Fisherman's UUID" do
          expect(sign_up_fisherman).to be == :aggregate_root_uuid
        end
      end
    end

    describe "Fishing business commands" do
      describe "#set_fisherman_up_in_business" do
        def set_fisherman_up_in_business
          poseidon.set_fisherman_up_in_business(
            fisherman_uuid: :fisherman_uuid,
            fishing_ground_uuid: :fishing_ground_uuid
          )
        end

        it "gets the Fisherman" do
          fisherman_registrar.should_receive(:get_by_id).with(:fisherman_uuid)
          set_fisherman_up_in_business
        end

        it "gets the FishingGround" do
          fishing_world.should_receive(:get_by_id).with(:fishing_ground_uuid)
          set_fisherman_up_in_business
        end

        it "tells the Fisherman to set up in business in the FishingGround" do
          fisherman.should_receive(:set_up_in_business_in).with(fishing_ground)
          set_fisherman_up_in_business
        end

        it "saves the Fisherman" do
          fisherman_registrar.should_receive(:update).with(fisherman)
          set_fisherman_up_in_business
        end

        it "saves the FishingGround" do
          fishing_world.should_receive(:update).with(fishing_ground)
          set_fisherman_up_in_business
        end
      end

      describe "#send_boat_out_to_sea" do
        def send_boat_out_to_sea
          poseidon.send_boat_out_to_sea(
            fishing_ground_uuid:   :aggregate_root_uuid,
            fishing_business_uuid: :business_uuid,
            order: 5
          )
        end

        it "finds the FishingGround" do
          fishing_world.should_receive(:get_by_id).with(:aggregate_root_uuid)
          send_boat_out_to_sea
        end

        it "sends the boat out" do
          fishing_ground.should_receive(:send_boat_out_to_sea).with(:business_uuid, 5)
          send_boat_out_to_sea
        end

        it "saves the FishingGround" do
          fishing_world.should_receive(:save).with(fishing_ground)
          send_boat_out_to_sea
        end
      end
    end
  end
end
