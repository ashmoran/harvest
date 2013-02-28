namespace :guard do
  desc "Run guard with the default adapter"
  task :default do
    system "guard"
  end

  desc "Run guard with the HTTP adapter"
  task :http do
    system "HARVEST_INTERFACE=http guard"
  end
end