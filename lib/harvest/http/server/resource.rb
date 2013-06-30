require 'webmachine/resource'

module Harvest
  module HTTP
    module Server
      class Resource < Webmachine::Resource
        ENVIRONMENT_OBJECTS = %i[ harvest_app base_uri cache_path ]
        attr_reader(*ENVIRONMENT_OBJECTS)

        # We need a hook in Webmachine::Resource.new
        class << self
          def new(request, response, resource_environment)
            instance = super(request, response)
            instance.instance_variable_set(:@request, request)
            instance.instance_variable_set(:@response, response)
            new_refinements(instance, resource_environment)
            instance.send :initialize
            instance
          end

          def new_refinements(instance, resource_environment)
            ENVIRONMENT_OBJECTS.each do |environment_object|
              instance.instance_variable_set(
                :"@#{environment_object}",
                resource_environment.fetch(environment_object)
              )
            end

            instance.instance_variable_set(:@base_uri, resource_environment.fetch(:base_uri))
            instance.instance_variable_set(:@cache_path, resource_environment.fetch(:cache_path))
          end
        end
      end
    end
  end
end