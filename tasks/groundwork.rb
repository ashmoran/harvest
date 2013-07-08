require 'fileutils'

namespace :groundwork do
  desc "Import GroundworkCSS files"
  task :import => [
    :import_javascript,
    :import_fonts,
    :import_images
  ]

  task :import_javascript do
    # Core Groundwork
    FileUtils.mkdir_p("web_client/site/lib/groundwork")
    FileUtils.cp("web_client/vendor/groundwork/js/groundwork.all.js", "web_client/site/lib/groundwork")

    # Libs
    FileUtils.mkdir_p("web_client/site/lib/groundwork")
    Dir.glob("web_client/vendor/groundwork/js/libs/*").reject { |file|
      # We have our own version of jQuery (we may have our own version of others in future)
      file =~ %r{/jquery}
    }.each do |file|
      FileUtils.cp(file, "web_client/site/lib/groundwork/")
    end

    # Plugins
    FileUtils.cp_r("web_client/vendor/groundwork/js/plugins", "web_client/site/lib/groundwork/")
  end

  task :import_fonts do
    Dir.glob("web_client/vendor/groundwork/fonts/*").each do |file|
      FileUtils.cp(file, "web_client/site/fonts")
    end
  end

  task :import_images do
    # Not doing this yet, until we know we actually want some of these
  end
end