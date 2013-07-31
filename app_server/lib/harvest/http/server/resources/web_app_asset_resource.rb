module Harvest
  module HTTP
    module Server
      module Resources
        # Hacked version of StaticFileResource to serve pages
        class WebAppAsset < Resource
          # Interim step, we need to remove knowledge of web files
          SOURCE_DIR = PROJECT_DIR + '/web_client/www'

          # Return only one content type, chosen based on the file requested.
          # Maybe this will generalise as a static file resource?
          def content_types_provided
            [ [ 'text/html', :file_contents ] ]
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
            File.expand_path(SOURCE_DIR + "/pages/" + request.disp_path + "/index.html")
          end
        end
      end
    end
  end
end
