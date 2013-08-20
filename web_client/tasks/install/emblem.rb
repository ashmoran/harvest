require 'emblem/source'

namespace :install do
  desc "Install Emblem"
  task :emblem do
    FileUtils.cp(Emblem::Source.bundled_path, "vendor/lib/")
  end
end