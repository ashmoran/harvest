require 'fileutils'

namespace :compass do
  desc "Install Zurb Foundation"
  task :install => %i[
    compass:foundation:install
    compass:foundation:cleanup
  ]

  namespace :foundation do
    task :install do
      system "compass install foundation -c compass.rb"
    end

    task :cleanup do
      FileUtils.rm("humans.txt")
      FileUtils.rm("index.html")
      FileUtils.rm("MIT-LICENSE.txt")
      FileUtils.rm("robots.txt")

      if File.directory?(".sass-cache")
        FileUtils.rm_rf(".sass-cache")
      else
        raise "Compass has stopped creating .sass-cache/"
      end

      FileUtils.mv("vendor/lib/vendor/custom.modernizr.js", "vendor/lib")
      FileUtils.mv("vendor/lib/vendor/zepto.js", "vendor/lib")
      # Don't take Foundation's jQuery, just nuke the directory next
      FileUtils.rm_rf("vendor/lib/vendor")
    end
  end
end