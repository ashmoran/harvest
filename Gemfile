source 'https://rubygems.org'

ruby '2.0.0'

gem 'realm', path: '../../realm/realm'

gem 'celluloid'
gem 'webmachine'
gem 'reel', '>= 0.4.0.pre'
gem 'roar', '~> 0.11.19'
gem 'representable', '~> 1.5.3' # Something in 1.6 breaks our code
gem 'virtus'
gem 'frenetic'

# Don't bulk require with the Ruby 2.0 bug still around
# "TypeError: nil can't be coerced into Fixnum"
gem 'facets', require: nil
gem 'uuidtools'
gem 'state_machine'

group :development do
	gem 'consular'
	gem 'consular-osx'

	gem 'rake'

	gem 'guard'
	gem 'rb-fsevent'
  gem 'growl'
  gem 'terminal-notifier-guard'

  gem 'guard-rake'

	gem 'guard-process', git: 'https://github.com/socialreferral/guard-process.git'

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

	gem 'nanoc'
	gem 'guard-nanoc'
	gem 'nutils'

	gem 'slim'
	gem 'sass'
	gem 'compass'
	gem 'zurb-foundation'
	gem 'coffee-script'
	gem 'emblem-source'

	gem 'heroku'
	gem 'pry'

	gem 'awesome_print'
	gem 'term-ansicolor'
end
