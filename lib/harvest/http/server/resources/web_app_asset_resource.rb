require 'slim'

module Harvest
  module HTTP
    module Server
      module Resources
        class WebAppAsset < Resource
          def content_types_provided
            # Turns out it's may be a mistake to overload this resource -
            # putting 'application/javascript' first to trick the server
            # into returning it when Chrome requests it from a script tag
            [
              # This probably won't work with IE8
              # http://www.2ality.com/2011/08/javascript-media-type.html
              ['application/javascript',  :file_contents],
              ['text/html',               :template]
            ]
          end

          def trace?
            true
          end

          def template
            template = case request.disp_path
              when 'play'
                File.expand_path(__dir__ + '/../../server/webapp/app/pages/index.html.slim')
              end

            Slim::Template.new(template, pretty: true).render
          end

          def file_contents
            File.read(__dir__ + "/../webapp/lib/" + request.path_tokens.join("/"))
          end
        end
      end
    end
  end
end
