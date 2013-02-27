require 'spec_helper'

require 'cqedomain/bus'
require 'harvest/domain' # Because the aggregate roots store EventTypes in Harvest::Domain::Events
require 'harvest/event_handlers/read_models/fishing_business_statistics'

module Harvest
  module EventHandlers
    module ReadModels
      describe FishingGroundStatistics do
        let(:database) {
          mock(
            "ReadModelDatabase",
            save: nil,
            delete: nil,
            records: [
              { uuid: :uuid_1, data: "data 1a" },
              { uuid: :uuid_1, data: "data 1b" },
              { uuid: :uuid_2, data: "data 2a" }
            ],
            count: 3
          )
        }

        let(:event_bus) { CQEDomain::Bus::SimpleEventBus.new }
        subject(:view) { FishingGroundStatistics.new(database) }

        before(:each) do
          event_bus.register(:unhandled_event, UnhandledEventErrorRaiser.new)
        end

        describe "#handle_new_fishing_business_opened" do
          before(:each) do
            event_bus.register(:new_fishing_business_opened, view)
          end

          it "saves the view info" do
            database.should_receive(:save).with(
              fishing_ground_uuid:   :fishing_ground_uuid,
              fishing_business_uuid: :fishing_business_uuid,
              lifetime_fish_caught:  0,
              lifetime_profit:       Harvest::Domain::Currency.dollar(0)
            )

            event_bus.publish(
              Domain::Events.build(
                :new_fishing_business_opened,
                uuid:                   :fishing_ground_uuid,
                fishing_business_uuid:  :fishing_business_uuid,
                fishing_business_name:  "Fishing Company Ltd"
              )
            )
          end
        end

        describe "#handle_fishing_order_fulfilled" do
          before(:each) do
            event_bus.register(:fishing_order_fulfilled, view)
          end

          before(:each) do
            database.stub(
              records: [
                {
                  fishing_ground_uuid:    :fishing_ground_uuid,
                  fishing_business_uuid:  :fishing_business_uuid,
                  lifetime_fish_caught:   3,
                  lifetime_profit:        Harvest::Domain::Currency.dollar(15)
                },
                {
                  fishing_ground_uuid:    :fishing_ground_uuid,
                  fishing_business_uuid:  :wrong_business_uuid,
                  lifetime_fish_caught:   10,
                  lifetime_profit:        Harvest::Domain::Currency.dollar(50)
                },
                {
                  fishing_ground_uuid:    :wrong_fishing_ground_uuid,
                  fishing_business_uuid:  :fishing_business_uuid,
                  lifetime_fish_caught:   0,
                  lifetime_profit:        Harvest::Domain::Currency.dollar(0)
                }
              ]
            )
          end

          it "updates the view info" do
            database.should_receive(:update).with(
              [:fishing_ground_uuid, :fishing_business_uuid],

              fishing_ground_uuid:   :fishing_ground_uuid,
              fishing_business_uuid: :fishing_business_uuid,
              lifetime_fish_caught:  8,
              lifetime_profit:       Harvest::Domain::Currency.dollar(40)
            )

            event_bus.publish(
              Domain::Events.build(
                :fishing_order_fulfilled,
                uuid:                   :fishing_ground_uuid,
                fishing_business_uuid:  :fishing_business_uuid,
                number_of_fish_caught:  5
              )
            )
          end
        end

        describe "#count" do
          it "is the number of records in the database" do
            expect(view.count).to be == 3
          end
        end

        describe "#records" do
          it "is the database records" do
            expect(view.records).to be == [
              { uuid: :uuid_1, data: "data 1a" },
              { uuid: :uuid_1, data: "data 1b" },
              { uuid: :uuid_2, data: "data 2a" }
            ]
          end
        end

        describe "#record_for" do
          before(:each) do
            database.stub(
              records: [
                { uuid: :uuid_1, data: "data a", extra: "extra data" },
                { uuid: :uuid_1, data: "data b", extra: "extra data" },
                { uuid: :uuid_2, data: "data b", extra: "extra data" }
              ]
            )
          end

          it "returns the record for the query" do
            record = view.record_for(uuid: :uuid_1, data: "data b")

            expect(record).to be == { uuid: :uuid_1, data: "data b", extra: "extra data" }
          end
        end
      end
    end
  end
end