require 'spec_helper'

require 'cqedomain/event_store'
require 'harvest/domain'

module Harvest
  module Domain
    describe FishingWorld do
      let(:event_store) {
        mock(CQEDomain::EventStore::EventStore, save_events: nil, history_for_aggregate: [ :old_event_1, :old_event_2 ])
      }
      subject(:fishing_world) { FishingWorld.new(event_store) }

      it "is an EventStoreRepository" do
        # We've reduced the implementation of these to little more than naming...
        expect(fishing_world.class).to be_a(CQEDomain::Domain::EventStoreRepository)
      end
    end
  end
end
