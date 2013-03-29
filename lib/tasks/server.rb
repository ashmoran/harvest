desc "Run a webapp server"
task :server do
  # Duplicated from .pryrc (with some changes)
  require 'harvest'
  require 'harvest/http/server'
  app = Harvest::App.new
  server = Harvest::HTTP::Server::HarvestHTTPServer.new(harvest_app: app, port: 3100)

  server.start
  puts "Server started"

  # Guard::Process sends TERM
  trap("TERM") do
    server.terminate
    server.join
    exit 0
  end

  sleep
end