require 'term/ansicolor'

desc "Validate against all specifications"
task :validate => %i[
  spec:cucumber:domain
  spec:cucumber:http
  spec:rspec
  spec:check_failure
]

namespace :spec do
  include Term::ANSIColor
  failures = [ ]

  namespace :cucumber do
    desc "Validate agains Cucumber specs (domain interface)"
    task :domain do
      system "HARVEST_INTERFACE=domain cucumber"
      failures << "cucumber/domain" if $? != 0
    end

    desc "Validate agains Cucumber specs (HTTP interface)"
    task :http do
      system "HARVEST_INTERFACE=http cucumber"
      failures << "cucumber/http" if $? != 0
    end
  end

  desc "Validate agains RSpec specs"
  task :rspec do
    system "rspec"
    failures << "rspec" if $? != 0
  end

  task :check_failure do
    if !failures.empty?
      puts
      fail "\n#{red(bold("Validation failed:"))} #{cyan(failures.join(", "))}\n\n"
    end
  end
end