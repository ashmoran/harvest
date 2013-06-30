require 'fileutils'

namespace :groundwork do
  desc "Import GroundworkCSS files"
  task :import => [
    :import_sass,
    :import_javascript,
    :import_fonts,
    :import_images
  ]

  task :import_sass do
    FileUtils.rm_rf("lib/harvest/http/server/webapp/styles/groundwork")
    FileUtils.cp_r("../groundwork/src/scss", "lib/harvest/http/server/webapp/styles/groundwork")
  end

  task :import_javascript do
    # Core Groundwork
    FileUtils.rm_rf("lib/harvest/http/server/webapp/lib/groundwork")
    FileUtils.mkdir_p("lib/harvest/http/server/webapp/lib/groundwork")
    FileUtils.cp("../groundwork/js/groundwork.all.js", "lib/harvest/http/server/webapp/lib/groundwork/")

    # Libs
    FileUtils.mkdir_p("lib/harvest/http/server/webapp/lib/groundwork/libs")
    Dir.glob("../groundwork/js/libs/*").reject { |file|
      file =~ %r{/jquery}
    }.each do |file|
      FileUtils.cp(file, "lib/harvest/http/server/webapp/lib/groundwork/libs")
    end

    # Plugins
    FileUtils.cp_r("../groundwork/js/plugins", "lib/harvest/http/server/webapp/lib/groundwork/")
  end

  task :import_fonts do
    FileUtils.rm_rf("lib/harvest/http/server/webapp/fonts/groundwork")
    FileUtils.cp_r("../groundwork/fonts", "lib/harvest/http/server/webapp/fonts/groundwork")
  end

  task :import_images do
    FileUtils.rm_rf("lib/harvest/http/server/webapp/images/groundwork")
    FileUtils.cp_r("../groundwork/images", "lib/harvest/http/server/webapp/images/groundwork")
  end
end