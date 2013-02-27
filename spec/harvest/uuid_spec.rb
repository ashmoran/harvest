require 'spec_helper'

require 'harvest/uuid'

describe Harvest do
  describe ".uuid" do
    it "is a UUID" do
      expect(Harvest.uuid).to be_a(UUIDTools::UUID)
    end
  end
end
