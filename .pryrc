$LOAD_PATH.unshift(Dir.pwd + '/lib')

def start_server(port = 3100)
  require 'harvest'
  require 'harvest/http/server'
  @h = Harvest::App.new
  @s = Harvest::HTTP::Server::HarvestHTTPServer.new(harvest_app: @h, port: 3100)
  puts "Harvest app stored in @h, HTTP server stored in @s"
  @s.start
  puts "Server started"
  true
end
