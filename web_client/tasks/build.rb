require_relative 'build/content'
require_relative 'build/lib'

desc "Clean and re-build the web client site"
task :rebuild => %i[
  clean
  build
]

desc "Clean the build output folder"
task :clean do
  FileUtils.rm_rf("www")
  FileUtils.mkdir_p("www")
end

desc "Build everything"
task :build => %i[
  build:content
  build:lib
]
