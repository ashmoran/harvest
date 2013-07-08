namespace :site do
  desc "Build the web client site"
  task :build => %i[
    groundwork:import
    jslibs:import
  ]
end