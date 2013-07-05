# TODO: report
module Webmachine
  module Adapters
    class Reel
      # Monkeypatch
      def run
        options = {
          port: configuration.port,
          host: configuration.ip
        }.merge(configuration.adapter_options)
        ::Reel::Server.supervise(options[:host], options[:port], &method(:process))
      end
    end
  end
end
