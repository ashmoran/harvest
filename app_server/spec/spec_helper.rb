$LOAD_PATH.unshift(File.expand_path(__dir__ + '/../lib'))

PROJECT_DIR = File.expand_path(__dir__ + "/../..")

require 'support/test_response'

require 'realm'
require 'realm/spec'

require 'ap'
require 'webmock/rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    # Disable the `should` syntax
    c.syntax = :expect
  end
end