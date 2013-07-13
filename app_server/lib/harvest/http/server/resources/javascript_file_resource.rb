module Harvest
  module HTTP
    module Server
      module Resources
        class JavaScriptFileResource < Resource
          # Interim step, we need to remove knowledge of web files
          SOURCE_DIR = PROJECT_DIR + '/web_client/www/lib'

          def trace?
            false
          end

          def content_types_provided
            # This probably won't work with IE8
            # http://www.2ality.com/2011/08/javascript-media-type.html
            [ ['application/javascript', :file_contents] ]
          end

          def resource_exists?
            File.file?(filename)
          end

          private

          def file_contents
            File.read(filename)
          end

          def filename
            # TODO: protect against URI hacking
            File.expand_path(SOURCE_DIR + "/" + request.path_tokens.join("/"))
          end
        end
      end
    end
  end
end
