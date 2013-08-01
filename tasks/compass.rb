require 'fileutils'

namespace :compass do
  desc "Install Zurb Foundation"
  task :install_foundation => [ :compass_install, :compass_cleanup ]

  task :compass_install do
    system "compass install foundation -c web_client/compass.rb"
  end

  task :compass_cleanup do
    FileUtils.rm("web_client/humans.txt")
    FileUtils.rm("web_client/index.html")
    FileUtils.rm("web_client/MIT-LICENSE.txt")
    FileUtils.rm("web_client/robots.txt")

    if File.directory?("web_client/.sass-cache/")
      FileUtils.rm_rf("web_client/.sass-cache/")
    else
      raise "Compass has stopped creating web_client/.sass-cache/"
    end

    FileUtils.mv("web_client/vendor/lib/vendor/custom.modernizr.js", "web_client/vendor/lib")
    FileUtils.mv("web_client/vendor/lib/vendor/zepto.js", "web_client/vendor/lib")
    # Don't take Foundation's jQuery, just nuke the directory next
    FileUtils.rm_rf("web_client/vendor/lib/vendor")
  end
end