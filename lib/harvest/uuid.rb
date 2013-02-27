require 'uuidtools'

module Harvest
	def self.uuid
		UUIDTools::UUID.timestamp_create
	end
end