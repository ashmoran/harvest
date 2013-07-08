namespace :site do
  desc "Build the web client site"
  task :build => %i[
    site:clean
    groundwork:import
    jslibs:import
  ]

  task :clean do
    FileUtils.rm_rf("web_client/site")
    FileUtils.mkdir_p("web_client/site")

    FileUtils.mkdir_p("web_client/site/lib")
    FileUtils.mkdir_p("web_client/site/fonts")
    FileUtils.mkdir_p("web_client/site/images")
    FileUtils.mkdir_p("web_client/site/styles")
  end
end