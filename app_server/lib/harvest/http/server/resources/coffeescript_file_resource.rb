require 'coffee-script'

module Harvest
  module HTTP
    module Server
      module Resources
        class CoffeeScriptFileResource < Resource
          # Interim step, we need to remove knowledge of web templates
          # from the app server
          SOURCE_DIR = PROJECT_DIR + '/web_client/src/lib'

          def trace?
            true
          end

          def content_types_provided
            # This probably won't work with IE8
            # http://www.2ality.com/2011/08/javascript-media-type.html
            [ ['application/javascript', :compile_coffeescript] ]
          end

          def resource_exists?
            File.file?(coffeescript_filename)
          end

          private

          def compile_coffeescript
            CoffeeScript.compile(File.read(coffeescript_filename))
          end

          def coffeescript_filename
            # TODO: protect against URI hacking
            File.expand_path(SOURCE_DIR + "/" + coffescript_path_tokens.join("/"))
          end

          def coffescript_path_tokens
            request.path_tokens.dup.tap do |tokens|
              tokens.last.sub!(/\.js$/, ".coffee")
            end
          end
        end
      end
    end
  end
end
