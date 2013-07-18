require 'spec_helper'

require 'harvest/domain' # Because the aggregate roots store EventTypes in Harvest::Domain::Events
require 'harvest/event_handlers/read_models/fishing_grounds_available_to_join'

module Harvest
  module EventHandlers
    module ReadModels
      describe FishingGroundsAvailableToJoin do
        let(:database) {
          double(
            "ReadModelDatabase",
            save: nil,
            delete: nil,
            records: [ :record_1, :record_2 ],
            count: 3
          )
        }
        let(:event_bus) { Realm::Messaging::Bus::SimpleMessageBus.new }
        subject(:view) { FishingGroundsAvailableToJoin.new(database) }

        before(:each) do
          event_bus.register(:unhandled_event, Realm::Messaging::Bus::UnhandledMessageSentinel.new)
        end

        describe "#handle_fishing_ground_opened" do
          before(:each) do
            event_bus.register(:fishing_ground_opened, view)
          end

          it "saves the view info" do
            database.should_receive(:save).with(
              uuid: :uuid_1, name: "Fishing ground 1",
              starting_year: 2012, current_year: 2012
            )

            event_bus.publish(
              Domain::Events.build(
                :fishing_ground_opened,
                uuid:                 :uuid_1,
                name:                 "Fishing ground 1",
                starting_year:        2012,
                lifetime:             10,
                starting_population:  40,
                carrying_capacity:    50,
                order_fulfilment:     :sequential
              )
            )
          end
        end

        describe "#handle_year_advanced" do
          before(:each) do
            event_bus.register(:year_advanced, view)
          end

          before(:each) do
            database.stub(
              records: [
                {
                  uuid: :uuid_1, name: "Fishing ground 1",
                  starting_year: 2012, current_year: 2012
                }
              ]
            )
          end

          it "updates the view info" do
            database.should_receive(:update).with(
              [ :uuid ],
              uuid: :uuid_1, name: "Fishing ground 1",
              starting_year: 2012, current_year: 2013
            )

            event_bus.publish(
              Domain::Events.build(:year_advanced, years_passed: 1, new_year: 2013, uuid: :uuid_1)
            )
          end
        end

        describe "#handle_fishing_ground_closed" do
          before(:each) do
            event_bus.register(:fishing_ground_closed, view)
          end

          it "saves the view info" do
            database.should_receive(:delete).with(uuid: :uuid_1)

            event_bus.publish(
              Domain::Events.build(
                :fishing_ground_closed, uuid: :uuid_1, version: 1, timestamp: Time.now
              )
            )
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

        describe "#count" do
          it "is the number of records in the database" do
            expect(view.count).to be == 3
          end
        end

        describe "#records" do
          it "is the database records" do
            expect(view.records).to be == [ :record_1, :record_2 ]
          end
        end
      end
    end
  end
end
