require 'spec_helper'

require 'harvest/domain'

module Harvest
  module Domain
    class FishingGround
      # Nasty means of dependency injection because I wasn't prepared to design
      # a dependency injection system just for the sake of order fulfilment policies
      FishingOrderPolicies[:backwards] =
        Class.new do
          include OrderFulfilmentPolicies::OrderFulfilmentPolicy

          def each(&block)
            @target.keys.reverse.each do |key|
              yield(key, @target[key])
            end
          end
        end
    end

    describe FishingGround do
      describe "construction" do
        before(:each) do
          Harvest.stub(uuid: :generated_uuid)
        end

        context "with valid attributes" do
          subject(:fishing_ground) {
            FishingGround.create(
              name:                 "Fishing ground",
              starting_year:        2012,
              lifetime:             10,
              starting_population:  40,
              carrying_capacity:    50,
              order_fulfilment:     :random
            )
          }

          it "has an uncommitted fishing_ground_opened event" do
            expect(fishing_ground).to have_uncommitted_events(
              {
                message_type:           :fishing_ground_opened,
                uuid:                 :generated_uuid,
                name:                 "Fishing ground",
                starting_year:        2012,
                lifetime:             10,
                starting_population:  40,
                carrying_capacity:    50,
                order_fulfilment:     :random
              }
            )
          end
        end

        describe "with invalid attributes" do
          def attributes(overrides = { })
            {
              name:                 "Fishing ground",
              starting_year:        2012,
              lifetime:             10,
              starting_population:  40,
              carrying_capacity:    50,
              order_fulfilment:     :random
            }.merge(overrides)
          end

          it "rejects unknown order order fulfilment policies" do
            expect {
              FishingGround.create(attributes(order_fulfilment: :upside_down))
            }.to raise_error(Realm::Domain::ConstructionError) { |error|
              expect(error.message).to include('Unknown order fulfilment policy: "upside_down"')
            }
          end
        end
      end

      context "an open FishingGround" do
        let(:events) {
          [
            Events.build(:fishing_ground_opened, lifetime: 10, name: "Fishing ground", starting_year: 2012, starting_population: 40, carrying_capacity: 50, order_fulfilment: :sequential, uuid: :aggregate_uuid)
          ]
        }

        describe "#close" do
          subject(:fishing_ground) { FishingGround.load_from_history(events) }

          it "closes the FishingGround" do
            fishing_ground.close

            expect(fishing_ground).to have_uncommitted_events(
              { message_type: :fishing_ground_closed, uuid: :aggregate_uuid }
            )
          end
        end

        describe "#new_fishing_business_opened" do
          let(:fishing_business) { double(FishingBusiness, uuid: :fishing_business_uuid) }

          subject(:fishing_ground) { FishingGround.load_from_history(events) }

          it "opens a new FishingBusiness" do
            fishing_ground.new_fishing_business_opened(
              fishing_business, fishing_business_name: "Fishing Business name"
            )

            expect(fishing_ground).to have_uncommitted_events(
              {
                message_type:             :new_fishing_business_opened,
                uuid:                   :aggregate_uuid,
                fishing_business_uuid:  :fishing_business_uuid,
                fishing_business_name:  "Fishing Business name"
              }
            )
          end
        end
      end

      context "an open FishingGround with a FishingBusiness" do
        describe "#start_fishing" do
          let(:events) {
            [
              Events.build(:fishing_ground_opened, name: "Fishing ground", starting_year: 2012, lifetime: 10, starting_population: 40, carrying_capacity: 50, order_fulfilment: :sequential, uuid: :aggregate_uuid),
              Events.build(:new_fishing_business_opened, fishing_business_name: "Business 1", uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid)
            ]
          }

          subject(:fishing_ground) {
            FishingGround.load_from_history(events)
          }

          it "starts fishing" do
            fishing_ground.start_fishing

            expect(fishing_ground).to have_uncommitted_events(
              { message_type: :fishing_started, uuid: :aggregate_uuid }
            )
          end
        end

        describe "trying to #send_boat_out_to_sea before fishing has started" do
          let(:events) {
            [
              Events.build(:fishing_ground_opened, lifetime: 10, name: "Fishing ground", starting_year: 2012, starting_population: 40, carrying_capacity: 50, order_fulfilment: :sequential, uuid: :aggregate_uuid),
              Events.build(:new_fishing_business_opened, fishing_business_name: "Business 1", uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid)
            ]
          }

          subject(:fishing_ground) {
            FishingGround.load_from_history(events)
          }

          it "raises an error" do
            expect {
              fishing_ground.send_boat_out_to_sea(:business_uuid, 5)
            }.to raise_error(Realm::Domain::InvalidOperationError) { |error|
              expect(error.message).to include("Fishing must start before you can send a boat out to sea")
            }
          end
        end

        describe "a FishingBusiness trying to join after fishing has started" do
          let(:events) {
            [
              Events.build(:fishing_ground_opened,        name: "Fishing ground", starting_year: 2012, lifetime: 10, starting_population: 40, carrying_capacity: 50, order_fulfilment: :sequential, uuid: :aggregate_uuid),
              Events.build(:new_fishing_business_opened,  fishing_business_name: "Business 1", fishing_business_uuid: :business_uuid, uuid: :aggregate_uuid),
              Events.build(:fishing_started,              uuid: :aggregate_uuid)
            ]
          }

          let(:unused_fishing_business) { double(FishingBusiness, uuid: :fishing_business_uuid) }

          subject(:fishing_ground) {
            FishingGround.load_from_history(events)
          }

          it "raises an error" do
            expect {
              fishing_ground.new_fishing_business_opened(
                unused_fishing_business, fishing_business_name: "Fishing Business name"
              )
            }.to raise_error(Realm::Domain::InvalidOperationError) { |error|
              expect(error.message).to include("New businesses may not set up in a fishing ground once fishing has started")
            }
          end
        end

        describe "#send_boat_out_to_sea" do
          let(:events) {
            [
              Events.build(:fishing_ground_opened, name: "Fishing ground", starting_year: 2012, lifetime: 10, starting_population: 40, carrying_capacity: 50, order_fulfilment: :sequential, uuid: :aggregate_uuid),
              Events.build(:new_fishing_business_opened, fishing_business_name: "Business 1", uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid),
              Events.build(:fishing_started, uuid: :aggregate_uuid)
            ]
          }

          subject(:fishing_ground) {
            FishingGround.load_from_history(events)
          }

          context "valid Fishing Business" do
            it "submits the order" do
              fishing_ground.send_boat_out_to_sea(:business_uuid, 5)

              expect(fishing_ground).to have_uncommitted_events(
                {
                  message_type: :fishing_order_submitted, order: 5,
                  uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid
                }
              )
            end
          end

          context "unknown Fishing Business" do
            it "raises an error" do
              expect {
                fishing_ground.send_boat_out_to_sea(:wrong_business_uuid, 5)
              }.to raise_error(Realm::Domain::InvalidOperationError) { |error|
                expect(error.message).to include("Invalid FishingBusiness", "wrong_business_uuid")
              }
            end
          end
        end
      end

      describe "fishing over one year" do
        describe "changing the order fulfilment policy" do
          let(:events) {
            [
              Events.build(
                :fishing_ground_opened, name: "Fishing ground", order_fulfilment: :backwards, starting_year: 2012, lifetime: 10, starting_population: 40, carrying_capacity: 50, uuid: :aggregate_uuid
              ),
              Events.build(:new_fishing_business_opened, fishing_business_name: "Business 1", uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_1),
              Events.build(:new_fishing_business_opened, fishing_business_name: "Business 2", uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_2),
              Events.build(:fishing_started, uuid: :aggregate_uuid),
              Events.build(:fishing_order_submitted, order: 20, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_1),
              Events.build(:fishing_order_submitted, order: 30, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_2),
            ]
          }

          subject(:fishing_ground) {
            FishingGround.load_from_history(events)
          }

          it "uses the specified policy" do
            fishing_ground.end_current_year

            expect(fishing_ground).to have_uncommitted_events(
              { message_type: :fishing_order_unfulfilled, number_of_fish_caught: 0, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_1 },
              { message_type: :fishing_order_fulfilled,   number_of_fish_caught: 30,  uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_2 }
            )
          end
        end

        describe "#end_current_year" do
          let(:events) {
            [
              Events.build(:fishing_ground_opened,        name: "Fishing ground", starting_year: 2012, lifetime: 10, starting_population: 40, carrying_capacity: 50, order_fulfilment: :sequential, uuid: :aggregate_uuid),
              Events.build(:new_fishing_business_opened,  fishing_business_name: "Business 1", uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_1),
              Events.build(:new_fishing_business_opened,  fishing_business_name: "Business 2", uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_2),
              Events.build(:new_fishing_business_opened,  fishing_business_name: "Business 3", uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_3),
              Events.build(:fishing_started, uuid: :aggregate_uuid)
            ]
          }

          subject(:fishing_ground) {
            FishingGround.load_from_history(events + fishing_order_events)
          }

          context "all fishing orders are in" do
            context "fishing orders are within the current population" do
              let(:fishing_order_events) {
                [
                  Events.build(:fishing_order_submitted, order: 5,  uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_1),
                  Events.build(:fishing_order_submitted, order: 15, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_2),
                  Events.build(:fishing_order_submitted, order: 20, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_3)
                ]
              }

              it "fulfills the orders" do
                fishing_ground.end_current_year

                expect(fishing_ground).to have_uncommitted_events(
                  { message_type: :fishing_order_fulfilled, number_of_fish_caught: 5,  uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_1 },
                  { message_type: :fishing_order_fulfilled, number_of_fish_caught: 15, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_2 },
                  { message_type: :fishing_order_fulfilled, number_of_fish_caught: 20, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_3 }
                )
              end

              it "advances the year" do
                fishing_ground.end_current_year

                expect(fishing_ground).to have_uncommitted_events(
                  { message_type: :year_advanced, uuid: :aggregate_uuid, years_passed: 1, new_year: 2013 }
                )
              end
            end

            context "a fishing order exceeds the remaining population" do
              let(:fishing_order_events) {
                [
                  Events.build(:fishing_order_submitted, order: 5,  uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_1),
                  Events.build(:fishing_order_submitted, order: 15, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_2),
                  Events.build(:fishing_order_submitted, order: 41, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_3)
                ]
              }

              it "means the boat comes back empty" do
                fishing_ground.end_current_year

                expect(fishing_ground).to have_uncommitted_events(
                  { message_type: :fishing_order_fulfilled,   number_of_fish_caught: 5,  uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_1 },
                  { message_type: :fishing_order_fulfilled,   number_of_fish_caught: 15, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_2 },
                  { message_type: :fishing_order_unfulfilled, number_of_fish_caught: 0, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_3 }
                )
              end
            end
          end

          context "there are missing fishing orders" do
            let(:fishing_order_events) {
              [
                Events.build(:fishing_order_submitted, order: 5, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_1)
              ]
            }

            it "raises an error" do
              expect {
                fishing_ground.end_current_year
              }.to raise_error(Realm::Domain::InvalidOperationError) { |error|
                expect(error.message).to include("Only 1 of 3 businesses have submitted orders this year")
              }
            end
          end
        end

        describe "fishing over multiple years" do
          describe "#end_current_year" do
            let(:events) {
              [
                Events.build(:fishing_ground_opened,        name: "Fishing ground",               starting_year: 2012, lifetime: 10, starting_population: 40, carrying_capacity: 50, order_fulfilment: :sequential, uuid: :aggregate_uuid),
                Events.build(:new_fishing_business_opened,  fishing_business_name: "Business 1",  fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
                Events.build(:fishing_started,              uuid: :aggregate_uuid),
                Events.build(:fishing_order_submitted,      order: 40,                            fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
                Events.build(:year_advanced,                years_passed: 1, new_year: 2013,                       uuid: :aggregate_uuid),
                Events.build(:fishing_order_fulfilled,      number_of_fish_caught: 40,            fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
                Events.build(:fishing_order_submitted,      order: 0,                             fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid)
              ]
            }

            subject(:fishing_ground) {
              FishingGround.load_from_history(events)
            }

            it "advances the year" do
              fishing_ground.end_current_year

              expect(fishing_ground).to have_uncommitted_events(
                { message_type: :year_advanced, years_passed: 1, new_year: 2014, uuid: :aggregate_uuid }
              )
            end
          end
        end
      end

      describe "fishing until the end" do
        describe "#end_current_year" do
          let(:events) {
            [
              Events.build(:fishing_ground_opened,        name: "Fishing ground",               starting_year: 2012, lifetime: 3, starting_population: 40, carrying_capacity: 50, order_fulfilment: :sequential, uuid: :aggregate_uuid),
              Events.build(:new_fishing_business_opened,  fishing_business_name: "Business 1",  fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
              Events.build(:fishing_started,              uuid: :aggregate_uuid),

              Events.build(:fishing_order_submitted,      order: 0,                             fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
              Events.build(:year_advanced,                years_passed: 1, new_year: 2013,      uuid: :aggregate_uuid),
              Events.build(:fishing_order_fulfilled,      number_of_fish_caught: 0,             fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),

              Events.build(:fishing_order_submitted,      order: 0,                             fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
              Events.build(:year_advanced,                years_passed: 1, new_year: 2014,      uuid: :aggregate_uuid),
              Events.build(:fishing_order_fulfilled,      number_of_fish_caught: 0,             fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),

              Events.build(:fishing_order_submitted,      order: 0,                             fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid)
            ]
          }

          subject(:fishing_ground) {
            FishingGround.load_from_history(events)
          }

          it "advances the year" do
            fishing_ground.end_current_year

            expect(fishing_ground).to have_uncommitted_events(
              { message_type: :year_advanced, years_passed: 1, new_year: 2015 },
              { message_type: :fishing_ended },
              { message_type: :fishing_ground_closed }
            )
          end
        end
      end

      describe "fishing to extinction" do
        let(:events) {
          [
            Events.build(:fishing_ground_opened,        name: "Fishing ground",               starting_year: 2012, lifetime: 10, starting_population: 40, carrying_capacity: 50, order_fulfilment: :sequential, uuid: :aggregate_uuid),
            Events.build(:new_fishing_business_opened,  fishing_business_name: "Business 1",  fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
            Events.build(:fishing_started,              uuid: :aggregate_uuid),
            Events.build(:fishing_order_submitted,      order: 40,                            fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
            Events.build(:year_advanced,                years_passed: 1, new_year: 2013,      uuid: :aggregate_uuid),
            Events.build(:fishing_order_fulfilled,      number_of_fish_caught: 40,            fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
            Events.build(:fishing_order_submitted,      order: 1,                             fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid)
          ]
        }

        subject(:fishing_ground) {
          FishingGround.load_from_history(events)
        }

        it "has no more fish to catch" do
          fishing_ground.end_current_year

          expect(fishing_ground).to have_uncommitted_events(
            { message_type: :fishing_order_unfulfilled, number_of_fish_caught: 0, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_1 }
          )
        end
      end

      describe "regeneration" do
        context "fish population does not reach carrying capacity" do
          let(:events) {
            [
              Events.build(:fishing_ground_opened,        name: "Fishing ground",               starting_year: 2012, lifetime: 10, starting_population: 40, carrying_capacity: 50, order_fulfilment: :sequential, uuid: :aggregate_uuid),
              Events.build(:new_fishing_business_opened,  fishing_business_name: "Business 1",  fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
              Events.build(:fishing_started,              uuid: :aggregate_uuid),
              Events.build(:fishing_order_submitted,      order: 25,                            fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
            ]
          }

          subject(:fishing_ground) {
            FishingGround.load_from_history(events)
          }

          it "regenerates the fish" do
            fishing_ground.end_current_year

            expect(fishing_ground).to have_uncommitted_events(
              { message_type: :fish_regenerated, number_of_fish_regenerated: 15, new_population: 30, uuid: :aggregate_uuid }
            )
          end
        end

        context "fish population would exceed carrying capacity" do
          let(:events) {
            [
              Events.build(:fishing_ground_opened,        name: "Fishing ground",               starting_year: 2012, lifetime: 10, starting_population: 40, carrying_capacity: 50, order_fulfilment: :sequential, uuid: :aggregate_uuid),
              Events.build(:new_fishing_business_opened,  fishing_business_name: "Business 1",  fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
              Events.build(:fishing_started,              uuid: :aggregate_uuid),
              Events.build(:fishing_order_submitted,      order: 0,                             fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
            ]
          }

          subject(:fishing_ground) {
            FishingGround.load_from_history(events)
          }

          it "regenerates the fish up to the carrying capacity" do
            fishing_ground.end_current_year

            expect(fishing_ground).to have_uncommitted_events(
              { message_type: :fish_regenerated, number_of_fish_regenerated: 10, new_population: 50, uuid: :aggregate_uuid }
            )
          end
        end
      end

      describe "fishing for regenerated fish" do
        let(:events) {
          [
            Events.build(:fishing_ground_opened,        name: "Fishing ground",               starting_year: 2012, lifetime: 10, starting_population: 40, carrying_capacity: 50, order_fulfilment: :sequential, uuid: :aggregate_uuid),
            Events.build(:new_fishing_business_opened,  fishing_business_name: "Business 1",  fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid, uuid: :aggregate_uuid),
            Events.build(:fishing_started,              uuid: :aggregate_uuid),
            Events.build(:fishing_order_submitted,      order: 25,                            fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
            Events.build(:year_advanced,                years_passed: 1, new_year: 2013,      uuid: :aggregate_uuid),
            Events.build(:fishing_order_fulfilled,      number_of_fish_caught: 25,            fishing_business_uuid: :business_uuid_1, uuid: :aggregate_uuid),
            Events.build(:fish_regenerated,             new_population: 30,                   number_of_fish_regenerated: 15, uuid: :aggregate_uuid),
            Events.build(:fishing_order_submitted,      order: 30,                            uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_1)
          ]
        }

        subject(:fishing_ground) {
          FishingGround.load_from_history(events)
        }

        it "lets you catch these fish in a future year" do
          fishing_ground.end_current_year

          expect(fishing_ground).to have_uncommitted_events(
            { message_type: :fishing_order_fulfilled, number_of_fish_caught: 30, uuid: :aggregate_uuid, fishing_business_uuid: :business_uuid_1 }
          )
        end
      end

      describe "a closed FishingGround" do
        let(:events) {
          [
            Events.build(:fishing_ground_opened, name: "Fishing ground", starting_year: 2012, lifetime: 10, starting_population: 40, carrying_capacity: 50, order_fulfilment: :sequential, uuid: :aggregate_uuid),
            Events.build(:fishing_ground_closed, uuid: :aggregate_uuid)
          ]
        }

        subject(:fishing_ground) { FishingGround.load_from_history(events) }

        it "can't be closed" do
          expect {
            fishing_ground.close
          }.to raise_error(Realm::Domain::InvalidOperationError) { |error|
            expect(error.message).to be == "FishingGround is already closed"
          }
        end
      end
    end
  end
end
