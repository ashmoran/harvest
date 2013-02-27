require 'webmachine/resource'

module Harvest
  module HTTP
    module Server
      class Resource < Webmachine::Resource
        attr_reader :harvest_app, :base_uri

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
            instance.instance_variable_set(:@harvest_app, resource_environment.fetch(:harvest_app))
            instance.instance_variable_set(:@base_uri, resource_environment.fetch(:base_uri))
          end
        end
      end
    end
  end
end