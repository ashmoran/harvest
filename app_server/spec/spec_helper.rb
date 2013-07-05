$LOAD_PATH.unshift(File.expand_path(__dir__ + '/../lib'))

require 'cqedomain'
require 'cqedomain/spec'

require 'ap'
require 'webmock/rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    # Disable the `should` syntax
    c.syntax = :expect
  end
end