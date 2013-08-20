require 'nanoc'

namespace :build do
  desc "Build static site content"
  task :content do
    site = ::Nanoc::Site.new('.')
    site.compile
  end
end
