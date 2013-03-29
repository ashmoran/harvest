require 'slim'

module Harvest
  module HTTP
    module Server
      module Resources
        class WebAppAsset < Resource
          def content_types_provided
            # This probably won't work with IE8
            # http://www.2ality.com/2011/08/javascript-media-type.html
            [
              ['text/html',               :template],
              ['application/javascript',  :file_contents]
            ]
          end

          def trace?
            false
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
