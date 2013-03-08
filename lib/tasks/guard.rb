task :guard => :"guard:default"

namespace :guard do
  desc "Run guard with the default adapter"
  task :default do
    system "guard"
  end

  desc "Run guard in WIP mode with the default adapter"
  task :wip do
    system "GUARD_MODE=wip guard"
  end

  desc "Run guard with the HTTP adapter"
  task :http do
    system "HARVEST_INTERFACE=http guard"
  end

  namespace :http do
    desc "Run guard in WIP mode with the HTTP adapter"
    task :wip do
      system "GUARD_MODE=wip HARVEST_INTERFACE=http guard"
    end
  end
end