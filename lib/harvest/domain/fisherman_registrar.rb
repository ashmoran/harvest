module Harvest
  module Domain
    FishermanRegistrar =
      CQEDomain::Domain.event_store_repository("Harvest::Domain::Fisherman") do
        domain_term_for :save, :register
      end
  end
end
