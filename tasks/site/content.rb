require 'nanoc'

namespace :site do
  namespace :build do
    task :content do
      Dir.chdir('web_client') do
        site = ::Nanoc::Site.new('.')
        site.compile
      end
    end
  end
end
