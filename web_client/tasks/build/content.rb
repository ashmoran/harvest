require 'nanoc'

namespace :build do
  task :content do
    site = ::Nanoc::Site.new('.')
    site.compile
  end
end
