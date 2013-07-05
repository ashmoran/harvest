require 'slim'

module Harvest
  module HTTP
    module Server
      module Resources
        class WebAppAsset < Resource
          # Currently you have to also add this to server.rb
          KNOWN_ASSETS = {
            ''        => 'index.html.slim',
            'play'    => 'play/index.html.slim',
            'signup'  => 'signup.html.slim'
          }

          def content_types_provided
            [ ['text/html', :template] ]
          end

          def charsets_provided
            # Hijack the private #charset_nop message in the base Resource
            [ ['utf-8', :charset_nop] ]
          end

          def trace?
            true
          end

          def resource_exists?
            KNOWN_ASSETS.has_key?(request.disp_path)
          end

          def template
            template = KNOWN_ASSETS.fetch(request.disp_path)

            Slim::Template.new(template_path(template), pretty: true).render
          end

          private

          def template_path(template)
            File.expand_path(__dir__ + '/../../server/webapp/app/pages/' + template)
          end
        end
      end
    end
  end
end
