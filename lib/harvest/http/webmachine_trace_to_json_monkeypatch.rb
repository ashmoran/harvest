# TODO: report
module Webmachine
  module Trace
    class ResourceProxy
      if ResourceProxy.instance_methods.include?(:to_json)
        puts "WARNING! Overriding ResourceProxy#to_json"
      end

      def to_json
        @resource.to_json
      end
    end
  end
end
