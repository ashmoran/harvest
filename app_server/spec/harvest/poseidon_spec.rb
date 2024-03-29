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

    let(:command_bus) { double("CommandBus", send: :send_response) }

    subject(:poseidon) {
      Poseidon.new(
        command_bus: command_bus,
        repositories: {
          fishing_world:        fishing_world,
          fisherman_registrar:  fisherman_registrar
        }
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
          open_fishing_ground

          expect(Domain::FishingGround).to have_received(:create).with(
            uuid:                 :aggregate_root_uuid,
            name:                 "New fishing ground name",
            starting_year:        2012,
            lifetime:             10,
            starting_population:  40,
            carrying_capacity:    40
          )
        end

        it "saves the FishingGround" do
          open_fishing_ground
          expect(fishing_world).to have_received(:save).with(fishing_ground)
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
          start_fishing
          expect(fishing_world).to have_received(:get_by_id).with(:aggregate_root_uuid)
        end

        it "starts fishing" do
          start_fishing
          expect(fishing_ground).to have_received(:start_fishing)
        end

        it "saves the FishingGround" do
          start_fishing
          expect(fishing_world).to have_received(:save).with(fishing_ground)
        end
      end

      describe "#close_fishing_ground" do
        def close_fishing_ground
          poseidon.close_fishing_ground(uuid: :aggregate_root_uuid)
        end

        it "finds the FishingGround" do
          close_fishing_ground
          expect(fishing_world).to have_received(:get_by_id).with(:aggregate_root_uuid)
        end

        it "closes the FishingGround" do
          close_fishing_ground
          expect(fishing_ground).to have_received(:close)
        end

        it "saves the FishingGround" do
          close_fishing_ground
          expect(fishing_world).to have_received(:save).with(fishing_ground)
        end
      end

      describe "#end_year_in_fishing_ground" do
        def end_year_in_fishing_ground
          poseidon.end_year_in_fishing_ground(uuid: :aggregate_root_uuid)
        end

        it "finds the FishingGround" do
          end_year_in_fishing_ground
          expect(fishing_world).to have_received(:get_by_id).with(:aggregate_root_uuid)
        end

        it "ends the current year" do
          end_year_in_fishing_ground
          expect(fishing_ground).to have_received(:end_current_year)
        end

        it "saves the FishingGround" do
          end_year_in_fishing_ground
          expect(fishing_world).to have_received(:save).with(fishing_ground)
        end
      end
    end

    describe "Fisherman commands" do
      describe "#sign_up_fisherman" do
        let!(:response) {
          poseidon.sign_up_fisherman(
            username:       "username",
            email_address:  "email@example.com",
            password:       "password"
          )
        }

        it "sends a :sign_up_fisherman command" do
          expect(command_bus).to have_received(:send).with(
            message_matching(
              message_type_name:  :sign_up_fisherman,
              username:           "username",
              email_address:      "email@example.com",
              password:           "password"
            )
          )
        end

        it "returns the response" do
          expect(response).to be == :send_response
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
          set_fisherman_up_in_business
          expect(fisherman_registrar).to have_received(:get_by_id).with(:fisherman_uuid)
        end

        it "gets the FishingGround" do
          set_fisherman_up_in_business
          expect(fishing_world).to have_received(:get_by_id).with(:fishing_ground_uuid)
        end

        it "tells the Fisherman to set up in business in the FishingGround" do
          set_fisherman_up_in_business
          expect(fisherman).to have_received(:set_up_in_business_in).with(fishing_ground)
        end

        it "saves the Fisherman" do
          set_fisherman_up_in_business
          expect(fisherman_registrar).to have_received(:update).with(fisherman)
        end

        it "saves the FishingGround" do
          set_fisherman_up_in_business
          expect(fishing_world).to have_received(:update).with(fishing_ground)
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
          send_boat_out_to_sea
          expect(fishing_world).to have_received(:get_by_id).with(:aggregate_root_uuid)
        end

        it "sends the boat out" do
          send_boat_out_to_sea
          expect(fishing_ground).to have_received(:send_boat_out_to_sea).with(:business_uuid, 5)
        end

        it "saves the FishingGround" do
          send_boat_out_to_sea
          expect(fishing_world).to have_received(:save).with(fishing_ground)
        end
      end
    end
  end
end
