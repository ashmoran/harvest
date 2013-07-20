require 'bundler'
Bundler.setup

require 'ap'

PROJECT_DIR = Dir.pwd
$LOAD_PATH.unshift(File.expand_path(PROJECT_DIR + '/app_server/lib'))

def start_server(port = 3200)
  require 'harvest'
  require 'harvest/http/server'
  @h = Harvest::App.new
  @s = Harvest::HTTP::Server::HarvestHTTPServer.new(
    harvest_app:  @h,
    port:         port,
    cache_path:   File.expand_path(PROJECT_DIR + "/tmp/cache/#{port}")
  )
  puts "Harvest app stored in @h, HTTP server stored in @s"
  @s.start
  puts "Server started"
  true
end
