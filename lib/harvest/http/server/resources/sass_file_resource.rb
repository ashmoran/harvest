require 'sass'
require 'sass/plugin'
require 'compass'
# require 'digest/rmd160'

Sass.load_paths <<
  Compass::Frameworks::ALL.detect { |framework|
    framework.name == "compass"
  }.stylesheets_directory

# TODO: when we've got a usable GroundworkCSS gem, we can remove this
Sass.load_paths << File.expand_path(__dir__ + "/../webapp/styles/")

module Harvest
  module HTTP
    module Server
      module Resources
        # Compiles SCSS format Sass files
        class SassFileResource < Resource
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
              css_location:       css_cache_path,
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
            # TODO: remove duplication of styles/ between dispatcher and here
            File.join(sass_template_path, sass_path_tokens.join("/"))
          end

          def sass_template_path
            File.expand_path(__dir__ + "/../webapp/styles/")
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
            File.join(css_cache_path, request.path_tokens.join("/"))
          end

          # The folder all generated CSS will live in
          def css_cache_path
            File.join(cache_path, "css")
          end
        end
      end
    end
  end
end
