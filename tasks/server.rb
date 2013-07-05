$LOAD_PATH.unshift(File.expand_path(PROJECT_DIR + "/app_server/lib"))

desc "Run a webapp server"
task :server do
  # Duplicated from .pryrc (with some changes)
  require 'harvest'
  require 'harvest/http/server'
  app = Harvest::App.new
  server = Harvest::HTTP::Server::HarvestHTTPServer.new(
    harvest_app:  app,
    port:         3100,
    cache_path:   File.expand_path(PROJECT_DIR + "/tmp/cache/3100")
  )

  server.start
  puts "Server started"

  # Guard::Process sends TERM
  trap("TERM") do
    exit 0
  end

  trap("INT") do
    exit 0
  end

  sleep
end