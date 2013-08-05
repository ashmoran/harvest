require_relative 'build/content'
require_relative 'build/lib'

desc "Build the web client site"
task :rebuild => %i[
  clean
  build
]

task :clean do
  FileUtils.rm_rf("www")
  FileUtils.mkdir_p("www")
end

task :build => %i[
  build:content
  build:lib
]
