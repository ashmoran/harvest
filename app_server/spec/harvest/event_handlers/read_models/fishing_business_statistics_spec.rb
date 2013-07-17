require 'spec_helper'

require 'harvest/domain' # Because the aggregate roots store EventTypes in Harvest::Domain::Events
require 'harvest/event_handlers/read_models/fishing_business_statistics'

module Harvest
  module EventHandlers
    module ReadModels
      describe FishingBusinessStatistics do
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

        let(:event_bus) { Realm::Messaging::Bus::SimpleMessageBus.new }
        subject(:view) { FishingBusinessStatistics.new(database) }

        before(:each) do
          event_bus.register(:unhandled_event, Realm::Messaging::Bus::UnhandledMessageErrorRaiser.new)
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

        describe "querying" do
          before(:each) do
            database.stub(
              records: [
                { uuid: :uuid_1, data: "data a", extra: "extra data" },
                { uuid: :uuid_1, data: "data b", extra: "extra data" },
                { uuid: :uuid_2, data: "data b", extra: "extra data" }
              ]
            )
          end

          describe "#record_for" do
            it "returns the record for the query" do
              expect(
                view.record_for(uuid: :uuid_1, data: "data b")
              ).to be == { uuid: :uuid_1, data: "data b", extra: "extra data" }
            end

            it "returns only the first record" do
              expect(
                view.record_for(data: "data b")
              ).to be == { uuid: :uuid_1, data: "data b", extra: "extra data" }
            end
          end

          describe "#records_for" do
            it "returns all the records for the query" do
              expect(
                view.records_for(uuid: :uuid_1)
              ).to be == [
                { uuid: :uuid_1, data: "data a", extra: "extra data" },
                { uuid: :uuid_1, data: "data b", extra: "extra data" }
              ]
            end
          end
        end
      end
    end
  end
end