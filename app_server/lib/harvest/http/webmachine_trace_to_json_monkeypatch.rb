# TODO: report
module Webmachine
  module Trace
    class ResourceProxy
      def to_json
        @resource.to_json
      end
    end
  end
end
