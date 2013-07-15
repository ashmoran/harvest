require 'spec_helper'

require 'realm/bus'
require 'harvest/domain' # Because the aggregate roots store EventTypes in Harvest::Domain::Events
require 'harvest/event_handlers/read_models/fishing_ground_businesses'

module Harvest
  module EventHandlers
    module ReadModels
      describe FishingGroundBusinesses do
        let(:database) {
          double(
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
        let(:event_bus) { Realm::Bus::SimpleEventBus.new }
        subject(:view) { FishingGroundBusinesses.new(database) }

        before(:each) do
          event_bus.register(:unhandled_event, UnhandledEventErrorRaiser.new)
        end

        describe "#handle_new_fishing_business_opened" do
          before(:each) do
            event_bus.register(:new_fishing_business_opened, view)
          end

          it "saves the view info" do
            database.should_receive(:save).with(
              uuid:                   :fishing_ground_uuid,
              fishing_business_uuid:  :fishing_business_uuid,
              fishing_business_name:  "Fishing Company Ltd"
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

        describe "#records_for" do
          it "returns the records for the aggregate uuid" do
            expect(view.records_for(:uuid_1)).to be == [
              { uuid: :uuid_1, data: "data 1a" },
              { uuid: :uuid_1, data: "data 1b" }
            ]
          end
        end
      end
    end
  end
end
