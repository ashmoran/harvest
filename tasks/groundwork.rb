require 'fileutils'

namespace :groundwork do
  desc "Import GroundworkCSS files"
  task :import => [
    :import_fonts,
    :import_images
  ]

  task :import_fonts do
    Dir.glob("web_client/vendor/groundwork/fonts/*").each do |file|
      FileUtils.cp(file, "web_client/www/fonts")
    end
  end

  task :import_images do
    # Not doing this yet, until we know we actually want some of these
  end
end