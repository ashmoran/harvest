module Harvest
  module HTTP
    module Server
      module Resources
        # Should probably be "FishingGroundBusinessStatisticsServerResource" as
        # we're returning a whole set here
        class FishingBusinessStatisticsServerResource < Resource
          def trace?
            false
          end

          def content_types_provided
            [['application/hal+json', :to_json]]
          end

          def allowed_methods
            %W[ GET ]
          end

          def to_json
            Representations::FishingGroundBusinessStatistics.new(
              fishing_business_statistics: business_statistics_records
            ).to_json
          end

          private

          def business_statistics_records
            harvest_app.read_models[:fishing_business_statistics].records_for(
              fishing_ground_uuid: UUIDTools::UUID.parse(request.path_info[:uuid])
            )
          end
        end
      end
    end
  end
end
