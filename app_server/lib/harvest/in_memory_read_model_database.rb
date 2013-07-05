require 'facets/hash/subset'

class InMemoryReadModelDatabase
	class NonUniqueUpdateError < RuntimeError; end
	class RecordNotFoundError < RuntimeError; end

	def initialize
		reset
	end

	# Hack for Cucumber
	def reset
		@records = Array.new
	end

	def count
		@records.length
	end

	def records
		@records
	end

	def save(attributes)
		@records << attributes
	end

	def update(key_fields, new_record)
		query = new_record.subset(key_fields)
		record = find_record(query)
		record.merge!(new_record)
	end

	def delete(attributes)
		@records.delete_if { |record|
			attributes.all? { |key, value| record[key] == value }
		}
	end

	private

	def find_record(query)
		found_records =
			@records.select { |record|
				query.all? { |key, value| record[key] == value }
			}

		if found_records.empty?
			raise RecordNotFoundError.new("No records matched #{query.inspect}")
		end

		if found_records.length > 1
			raise NonUniqueUpdateError.new("Multiple records matched #{query.inspect}")
		end

		found_records.first
	end
end