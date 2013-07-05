module Harvest
  module HTTP
    module Server
      class ResourceCreator
        def initialize(resource_environment)
          @resource_environment = resource_environment.freeze
        end

        def call(route, request, response)
          begin
            # Assume it's a Harvest resource
            route.resource.new(request, response, @resource_environment)
          rescue ArgumentError
            # It's probably a standard Webmachine resource
            route.resource.new(request, response)
          end
        end
      end
    end
  end
end