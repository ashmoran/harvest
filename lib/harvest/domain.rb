require 'cqedomain/domain/event_factory'

module Harvest
  module Domain
    Events = CQEDomain::Domain::EventFactory.new
  end
end

require_relative 'domain/currency'
require_relative 'domain/fisherman'
require_relative 'domain/fisherman_registrar'
require_relative 'domain/fishing_business'
require_relative 'domain/fishing_ground'
require_relative 'domain/fishing_world'