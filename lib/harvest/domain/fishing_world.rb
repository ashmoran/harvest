module Harvest
  module Domain
    FishingWorld = CQEDomain::Domain.event_store_repository("Harvest::Domain::FishingGround")
  end
end
