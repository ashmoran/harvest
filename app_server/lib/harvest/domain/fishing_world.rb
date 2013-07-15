module Harvest
  module Domain
    FishingWorld = Realm::Domain.event_store_repository("Harvest::Domain::FishingGround")
  end
end
