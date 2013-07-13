require 'sass'
require 'sass/plugin'
require 'compass'
# require 'digest/rmd160'

# We only have to do this because Groundwork depends on it
Sass.load_paths <<
  Compass::Frameworks::ALL.detect { |framework|
    framework.name == "compass"
  }.stylesheets_directory

# TODO: when we've got a usable GroundworkCSS gem, we can remove this
# While /web_client/vendor is a bit broad, it lets us put "groundwork/" in the `@include`s
Sass.load_paths << File.expand_path(PROJECT_DIR + "/web_client/vendor")

module Harvest
  module HTTP
    module Server
      module Resources
        # Compiles SCSS format Sass files
        class SassFileResource < Resource
          # Interim step, we need to remove knowledge of web templates
          # from the app server
          SOURCE_DIR = PROJECT_DIR + '/web_client/src/styles'
          # The folder all generated CSS will live in
          TARGET_DIR = PROJECT_DIR + '/web_client/www/styles'

          def trace?
            true
          end

          def content_types_provided
            [ ['text/css', :compile_sass] ]
          end

          def resource_exists?
            File.file?(sass_filename)
          end

          # TODO: basic caching (on top of Sass not recompiling every time)
          # def generate_etag
          #   Digest::RMD160.hexdigest(css_file_content)
          # end

          private

          def compile_sass
            ensure_css_cache_dir_exists
            compiler = Sass::Plugin::Compiler.new(
              template_location:  sass_template_path,
              css_location:       TARGET_DIR,
              cache_location:     sass_cache_path
            )
            # You can pass individual stylesheets in here, but we don't bother...
            compiler.update_stylesheets
            css_file_content
          end

          def ensure_css_cache_dir_exists
            FileUtils.mkdir_p(File.dirname(css_cache_filename))
          end

          def sass_filename
            # TODO: protect against URI hacking
            File.expand_path(sass_template_path + "/" + sass_path_tokens.join("/"))
          end

          def sass_template_path
            SOURCE_DIR
          end

          def css_file_content
            File.read(css_cache_filename)
          end

          # Path tokens translated as if the request was made for the .scss file
          def sass_path_tokens
            # Remember: dup is not a deep copy
            tokens = request.path_tokens.dup
            tokens[-1] = tokens[-1].sub(/\.css$/, ".scss")
            tokens
          end

          # Where Sass will store it's compiled binary files
          def sass_cache_path
            File.join(cache_path, "sass")
          end

          # Full filename of the generated CSS
          def css_cache_filename
            # TODO: protect against URI hacking
            File.expand_path(TARGET_DIR + "/" + request.path_tokens.join("/"))
          end
        end
      end
    end
  end
end
