require 'cqedomain'
require 'cqedomain/spec'

require 'ap'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    # Disable the `should` syntax
    c.syntax = :expect
  end
end