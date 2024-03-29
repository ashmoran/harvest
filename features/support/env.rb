require 'facets/hash/slice'
require 'awesome_print'

PROJECT_DIR = File.expand_path(__dir__ + "/../..")

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../support"))
$LOAD_PATH.unshift(File.expand_path(PROJECT_DIR + "/app_server/lib"))

require 'harvest'

HARVEST_INTERFACE = ENV["HARVEST_INTERFACE"] || "domain"

require_relative 'harvest_world/harvest_world_core'

HarvestWorldInterface =
  case HARVEST_INTERFACE
  when "domain"
    require_relative 'harvest_world/harvest_world_domain'
    HarvestWorld::Domain
  when "http"
    require_relative 'harvest_world/harvest_world_http'
    HarvestWorld::HTTP
  when "web"
    require_relative 'harvest_world/harvest_world_web'
    HarvestWorld::Web
  else
    raise "Unknown Harvest interface: #{HARVEST_INTERFACE.inspect}"
  end

World(HarvestWorld::Core)
World(HarvestWorldInterface)

server_running = false

def print_errors(&block)
  begin
    block.call
  rescue Exception => e
    puts(e)
    puts(*e.backtrace)
    raise
  end
end

Before do
  print_errors do
    if !server_running
      run_app
      server_running = true
    end
  end
end

Before do
  print_errors do
    reset_app
  end
end