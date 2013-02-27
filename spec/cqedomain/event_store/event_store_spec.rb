require 'spec_helper'

require 'cqedomain/event_store'

module CQEDomain
  module EventStore
    describe UnknownAggregateRootError do
      subject(:error) { UnknownAggregateRootError.new(:test_uuid) }

      it "is a RuntimeError" do
        expect(error).to be_a(RuntimeError)
      end

      its(:message) { should be == "Unknown AggregateRoot: :test_uuid" }
    end
  end
end