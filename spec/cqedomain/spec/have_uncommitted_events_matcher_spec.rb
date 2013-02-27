require 'spec_helper'

require 'cqedomain/domain'
require 'cqedomain/spec'

describe "expect(aggregate_root).to have_uncommitted_events(...)" do
  let(:event_factory) { CQEDomain::Domain::EventFactory.new }

  subject(:aggregate_root) {
    mock(
      CQEDomain::Domain::AggregateRoot,
      uuid: :aggregate_uuid, uncommitted_events: uncommitted_events
    )
  }

  before(:each) do
    event_factory.define(:this_happened, :property_1, :property_2)
    event_factory.define(:that_happened, :property_a, :property_b)
  end

  context "no events" do
    let(:uncommitted_events) { [ ] }

    specify {
      expect(aggregate_root).to have_no_uncommitted_events
    }
  end

  context "events" do
    let(:uncommitted_events) {
      [
        event_factory.build(:this_happened, uuid: :aggregate_uuid, property_1: "one", property_2: "two"),
        event_factory.build(:this_happened, uuid: :aggregate_uuid, property_1: "ein", property_2: "zwei"),
        event_factory.build(:that_happened, uuid: :aggregate_uuid, property_a: "x", property_b: "y")
      ]
    }

    context "expecting no events" do
      it "expecting no uncommitted events raises an error about all the uncommitted events" do
        expect {
          expect(aggregate_root).to have_no_uncommitted_events
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError) { |error|
          expect(error.message).to include("this_happened", "that_happened", "one", "ein", "x")
        }
      end
    end

    context "expecting events" do
      it "complains about events that aren't in the uncommitted list" do
        expect {
          expect(aggregate_root).to have_uncommitted_events(
            { event_type: :this_happened, uuid: :aggregate_uuid, property_1: "wrong value", property_2: "two"   }
          )
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError) { |error|
          expect(error.message).to include("this_happened", "property_1", "wrong value")
        }
      end

      it "doesn't complain about a single event that matches" do
        expect {
          expect(aggregate_root).to have_uncommitted_events(
            { event_type: :this_happened, uuid: :aggregate_uuid, property_1: "ein", property_2: "zwei"  }
          )
        }.to_not raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "doesn't complain about multiple events that match" do
        expect {
          expect(aggregate_root).to have_uncommitted_events(
            { event_type: :this_happened, uuid: :aggregate_uuid, property_1: "one", property_2: "two"   },
            { event_type: :this_happened, uuid: :aggregate_uuid, property_1: "ein", property_2: "zwei"  },
            { event_type: :that_happened, uuid: :aggregate_uuid, property_a: "x",   property_b: "y"     }
          )
        }.to_not raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "complains if any events don't match" do
        expect {
          expect(aggregate_root).to have_uncommitted_events(
            { event_type: :this_happened, uuid: :aggregate_uuid, property_1: "one", property_2: "two"   },
            { event_type: :this_happened, uuid: :aggregate_uuid, property_1: "ein", property_2: "zwei"  },
            { event_type: :that_happened, uuid: :aggregate_uuid, property_a: "x",   property_b: "z"     }
          )
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError) { |error|
          expect(error.message).to include("that_happened", "property_b", "z")
        }
      end
    end
  end
end