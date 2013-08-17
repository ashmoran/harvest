require 'spec_helper'

require 'harvest/domain'
require 'harvest/event_handlers/read_models/registered_fishermen'

module Harvest
  module EventHandlers
    module ReadModels
      describe RegisteredFishermen do
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

        subject(:view) { RegisteredFishermen.new(database) }

        before(:each) do
          event_bus.register(:unhandled_event, Realm::Messaging::Bus::UnhandledMessageSentinel.new)
        end

        describe "#handle_fisherman_registered" do
          before(:each) do
            event_bus.register(:fisherman_registered, view)
          end

          it "saves the view info" do
            database.should_receive(:save).with(
              uuid: :uuid_1, name: "Fisherman Ahab"
            )

            event_bus.publish(
              Domain::Events.build(
                :fisherman_registered, uuid: :uuid_1, name: "Fisherman Ahab"
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
            expect(view.records).to be == [ :record_1, :record_2 ]
          end
        end
      end
    end
  end
end
