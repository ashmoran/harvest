require 'spec_helper'

require 'realm/event_store'
require 'harvest/domain'

module Harvest
  module Domain
    describe FishermanRegistrar do
      let(:event_store) {
        double(Realm::EventStore, save_events: nil, history_for_aggregate: [ :old_event_1, :old_event_2 ])
      }
      subject(:fisherman_registrar) { FishermanRegistrar.new(event_store) }

      it "is an EventStoreRepository" do
        # We've reduced the implementation of these to little more than naming...
        expect(fisherman_registrar.class).to be_a(Realm::Domain::EventStoreRepository)
      end
    end
  end
end
