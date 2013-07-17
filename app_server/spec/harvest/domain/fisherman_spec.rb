require 'spec_helper'

require 'harvest/domain'

module Harvest
  module Domain
    describe Fisherman do
      describe "construction" do
        subject(:fisherman) { Fisherman.create(name: "Fisherman Ahab") }

        before(:each) do
          Harvest.stub(uuid: :generated_uuid)
        end

        it "has an uncommitted :fisherman_registered event" do
          expect(fisherman).to have_uncommitted_events(
            { message_type: :fisherman_registered, uuid: :generated_uuid, name: "Fisherman Ahab" }
          )
        end
      end

      context "an open FishingGround" do
        let(:fishing_ground_events) {
          [
            Events.build(:fishing_ground_opened, uuid: :fishing_ground_uuid, name: "The Atlantic Ocean")
          ]
        }

        let(:fishing_ground) {
          double(FishingGround, uuid: :fishing_ground_uuid, new_fishing_business_opened: nil)
        }
        subject(:fisherman) { Fisherman.load_from_history(fisherman_events) }

        context "and a registered Fisherman" do
          let(:fisherman_events) {
            [
              Events.build(:fisherman_registered, uuid: :fisherman_uuid, name: "Captain Ahab")
            ]
          }

          describe "#set_up_in_business_in" do
            it "causes a fisherman_set_up_in_business_in event" do
              fisherman.set_up_in_business_in(fishing_ground)

              expect(fisherman).to have_uncommitted_events(
                { message_type: :fisherman_set_up_in_business_in, fishing_ground_uuid: :fishing_ground_uuid }
              )
            end

            it "notifies the FishingGround that business was set up" do
              fishing_ground.should_receive(:new_fishing_business_opened).with(
                fisherman, fishing_business_name: "Captain Ahab"
              )

              fisherman.set_up_in_business_in(fishing_ground)
            end
          end
        end

        context "and a Fisherman in business in the FishingGround" do
          let(:fisherman_events) {
            [
              Events.build(:fisherman_registered, uuid: :fisherman_uuid, name: "Captain Ahab"),
              Events.build(:fisherman_set_up_in_business_in, uuid: :fisherman_uuid, fishing_ground_uuid: :fishing_ground_uui)
            ]
          }

          describe "#set_up_in_business_in" do
            it "raises an error" do
              expect {
                fisherman.set_up_in_business_in(fishing_ground)
              }.to raise_error(Realm::Domain::InvalidOperationError) { |error|
                expect(error.message).to be == "Fisherman is already in business there"
              }

              expect(fisherman.uncommitted_events).to be_empty
            end
          end
        end
      end
    end
  end
end
