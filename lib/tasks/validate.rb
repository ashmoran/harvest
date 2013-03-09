require 'term/ansicolor'

desc "Validate against all specifications"
task :validate => %i[ spec:cucumber spec:rspec spec:check_failure ]

namespace :spec do
  include Term::ANSIColor
  failures = [ ]

  desc "Validate agains Cucumber specs (default interface)"
  task :cucumber do
    system "cucumber"
    failures << :cucumber if $? != 0
  end

  desc "Validate agains RSpec specs (default interface)"
  task :rspec do
    system "rspec"
    failures << :rspec if $? != 0
  end

  task :check_failure do
    if !failures.empty?
      puts
      fail "\n#{red(bold("Validation failed:"))} #{cyan(failures.join(", "))}\n\n"
    end
  end
end