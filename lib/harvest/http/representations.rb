require 'roar'
require 'roar/representer/json'
require 'roar/representer/json/hal'
require 'representable/coercion'

module Harvest; module HTTP; module Representations; end; end; end

require_relative 'representations/fisherman'
require_relative 'representations/fisherman_registrar'
require_relative 'representations/fishing_application'
require_relative 'representations/fishing_business_application'
require_relative 'representations/fishing_business_statistics'
require_relative 'representations/fishing_ground'
require_relative 'representations/fishing_ground_application'
require_relative 'representations/fishing_ground_business_statistics'
require_relative 'representations/fishing_world'
require_relative 'representations/harvest_home'
