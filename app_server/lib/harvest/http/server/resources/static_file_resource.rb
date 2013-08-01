module Harvest
  module HTTP
    module Server
      module Resources
        # TODO: Move all static file types in here
        class StaticFileResource < Resource
          # Interim step, we need to remove knowledge of web files
          SOURCE_DIR = PROJECT_DIR + '/web_client/www'

          FILE_EXTENSION_CONTENT_TYPES = {
            'css'     => 'text/css',
            'gif'     => 'image/gif',
            # This probably won't work with IE8
            # http://www.2ality.com/2011/08/javascript-media-type.html
            'js'      => 'application/javascript',
            'coffee'  => 'text/x-coffeescript',
            'map'     => 'application/json'
          }.freeze

          def trace?
            false
          end

          # Return only one content type, chosen based on the file requested.
          # Maybe this will generalise as a static file resource?
          def content_types_provided
            [ [ FILE_EXTENSION_CONTENT_TYPES[file_extension], :file_contents ] ]
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

          def file_extension
            request.path_tokens.last.split(".").last
          end
        end
      end
    end
  end
end
