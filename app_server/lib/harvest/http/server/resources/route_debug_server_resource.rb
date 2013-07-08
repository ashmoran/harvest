module Harvest
  module HTTP
    module Server
      module Resources
        class RouteDebugServerResource < Webmachine::Resource
          def resource_exists?
            response.body = to_html
            false
          end

          # Not called by the Webmachine flow as #resource_exists? returns false
          def to_html
            <<-HTML
              <html>
                <head><title>404 Not Found</title></head>
                <body>
                  <h1>404 Not Found</h1>
                  <strong>request.disp_path</strong>
                  <pre>#{request.disp_path}</pre>
                  <strong>request.path_info</strong>
                  <pre>#{request.path_info}</pre>
                  <strong>request.path_tokens</strong>
                  <pre>#{request.path_tokens}</pre>
                </body>
              </html>
            HTML
          end
        end
      end
    end
  end
end