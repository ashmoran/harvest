module Harvest
  module HTTP
    module Server
      module Resources
        class FontFileResource < Resource
          FILE_EXTENSION_CONTENT_TYPES = {
            'woff'  => 'application/font-woff',
            # application/x-font-ttf could be application/octet-stream:
            # http://stackoverflow.com/questions/2871655/proper-mime-type-for-fonts
            'ttf'   => 'application/x-font-ttf',
            'svg'   => 'image/svg+xml',
            # Untested, presumably Groundwork will only request these files from within IE:
            'eot'   => 'application/vnd.ms-fontobject',
            'otf'   => 'application/vnd.ms-opentype'
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
            # TODO: remove duplication of fonts/ between dispatcher and here
            File.expand_path(__dir__ + "/../webapp/fonts/" + request.path_tokens.join("/"))
          end

          def file_extension
            request.path_tokens.last.split(".").last
          end
        end
      end
    end
  end
end
