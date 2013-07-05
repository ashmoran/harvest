module Harvest
  module HTTP
    module Server
      module Resources
        class RouteDebugServerResource < Webmachine::Resource
          def to_html
            <<-HTML
              <html>
                <head><title>Test from Webmachine</title></head>
                <body>
                  <h5>request.disp_path</h5>
                  <pre>#{request.disp_path}</pre>
                  <h5>request.path_info</h5>
                  <pre>#{request.path_info}</pre>
                  <h5>request.path_tokens</h5>
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