require 'zurb-foundation'

# -----------------------------------------------
# Paths
# -----------------------------------------------

http_path = "/"

project_path = "."

sass_dir  = "src/content/styles"
css_dir   = "www/styles"

images_dir            = "src/content/images"
generated_images_dir  = "www/images" # Might clash with other build steps?

javascripts_dir = "vendor/lib"


# -----------------------------------------------
# Output
# -----------------------------------------------

output_style = :nested
preferred_syntax = :scss
relative_assets = true

sass_options = {
  cache_location: 'tmp/cache/sass',
  syntax:         :scss
}


# -----------------------------------------------
# Silence SublimeLinter warnings
# -----------------------------------------------

[
  http_path, project_path, sass_dir, css_dir, images_dir,
  generated_images_dir, javascripts_dir, output_style,
  preferred_syntax, relative_assets, sass_options
]