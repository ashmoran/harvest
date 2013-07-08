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
  end
end