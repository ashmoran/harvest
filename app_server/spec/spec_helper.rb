$LOAD_PATH.unshift(File.expand_path(__dir__ + '/../lib'))

PROJECT_DIR = File.expand_path(__dir__ + "/../..")

require 'support/test_response'
require 'support/resource_context'

require 'realm'
require 'realm/spec'

require 'ap'
require 'webmock/rspec'

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    # Disable the `should` syntax
    c.syntax = :expect
  end

  config.before(:each, allow_net_connect: true) do
    WebMock.allow_net_connect!
  end
  config.after(:each, allow_net_connect: true) do
    WebMock.disable_net_connect!
  end
end