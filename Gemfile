source 'https://rubygems.org'

ruby '2.0.0'

gem 'realm', path: '../../realm/realm'

gem 'webmachine'
gem 'reel', '>= 0.4.0.pre'
gem 'roar'
gem 'representable'
gem 'virtus'
gem 'frenetic'

gem 'slim'
gem 'sass'
gem 'compass'
gem 'coffee-script'

gem 'rake'

# Don't bulk require with the Ruby 2.0 bug still around
# "TypeError: nil can't be coerced into Fixnum"
gem 'facets', require: nil
gem 'uuidtools'
gem 'state_machine'

group :development do
	gem 'guard'
	gem 'rb-fsevent'
  gem 'growl'
  gem 'terminal-notifier-guard'

  gem 'guard-rake'

  # Maintaining our own copy in lib/guard
	# gem 'guard-process'
	# but we still need the dependencies...
	gem 'ffi'
	gem 'spoon'

	gem 'cucumber'
	gem 'guard-cucumber'
	gem 'relish'
	gem 'capybara'
	gem 'capybara-webkit'

	gem 'rspec'
	gem 'guard-rspec'
	gem 'fuubar'
	gem 'webmock'

	gem 'guard-mocha-node'

	# Our fake "HTML build process" is making sure Guard::Slim is running...
	gem 'guard-slim'
	gem 'nanoc'
	gem 'guard-nanoc'
	gem 'nutils'

	gem 'heroku'
	gem 'pry'

	gem 'awesome_print'
	gem 'term-ansicolor'
end
