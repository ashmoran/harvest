namespace :site do
  desc "Build the web client site"
  task :build => %i[
    site:clean
    groundwork:import
    jslibs:import
  ]

  task :clean do
    FileUtils.rm_rf("web_client/www")
    FileUtils.mkdir_p("web_client/www")

    FileUtils.mkdir_p("web_client/www/lib")
    FileUtils.mkdir_p("web_client/www/fonts")
    FileUtils.mkdir_p("web_client/www/images")
    FileUtils.mkdir_p("web_client/www/styles")
  end
end