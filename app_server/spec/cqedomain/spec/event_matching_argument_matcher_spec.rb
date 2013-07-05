require 'spec_helper'

require 'cqedomain/domain'
require 'cqedomain/spec'

module CQEDomain
  module Spec
    describe EventMatchingArgumentMatcher do
      let(:event_type) {
        CQEDomain::Domain::EventFactory::EventType.new(:test_event_type, [ :foo ])
      }
      subject(:event) { event_type.new_event(event_type: :test_event_type, uuid: :test_uuid, foo: "bar") }

      it "matches when it matches" do
        expect(event_matching(event_type: :test_event_type, uuid: :test_uuid, foo: "bar")).to be == event
      end

      it "doesn't match when it doesn't match" do
        expect(event_matching(event_type: :test_event_type, uuid: :test_uuid, foo: "baz")).to_not be == event
      end
    end
  end
end