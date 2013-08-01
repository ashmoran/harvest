require_relative 'site/content'
require_relative 'site/lib'

namespace :site do
  desc "Build the web client site"
  task :rebuild => %i[
    site:clean
    site:build
  ]

  task :clean do
    FileUtils.rm_rf("web_client/www")
    FileUtils.mkdir_p("web_client/www")
  end

  task :build => %i[
    site:build:content
    site:build:lib
  ]
end