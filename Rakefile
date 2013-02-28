require_relative 'lib/tasks/darcs_git'

desc "Start a web server"
task :server do
  system "thin -R config.ru start"
end

desc "Push to Darcs Hub and GitHub"
task :push do
  puts 'Running `darcs push`:'
  puts
  system "darcs push"
  puts

  puts 'Running `git push`:'
  puts
  system "git push"
end

namespace :darcs do
  namespace :amend_record do
    desc "darcs amend-record Harvest files"
    task :harvest do
      system "darcs amend-record -a lib/harvest spec/harvest"
    end

    desc "darcs amend-record CQEDomain files"
    task :cqedomain do
      system "darcs amend-record -a lib/cqedomain spec/cqedomain"
    end
  end
end

desc "Alias: darcs:amend_record:harvest"
task :dah => :"darcs:amend_record:harvest"

desc "Alias: darcs:amend_record:cqedomain"
task :dac => :"darcs:amend_record:cqedomain"

namespace :deploy do
  def app_name
    @app_name ||= File.basename(Dir.getwd)
  end

  def run(command)
    puts "Running #{command}"
    system(command)
  end

  def clean_up
    run "rm -rf #{app_name}"
    run "rm -rf .git"
    run "rm -rf .bundle"
  end

  def deploy_code
    identifier = `date "+%Y-%m-%d-%H-%M-%S"`.chomp

    puts "***********************************"
    puts "* Deploying to: #{app_name}"
    puts "***********************************"
    puts

    puts "*** Updating local git repo ***"
    run "git clone git@heroku.com:#{app_name}.git -o heroku --depth 1"
    run "mv #{app_name}/.git ."
    run "rm -rf #{app_name}"

    bundle_for_heroku
    run "git add ."
    run "git commit -am '#{identifier}'"
    bundle_for_deploy
    puts

    puts "*** Deploying code changes to Heroku ***"
    run "git push heroku master"
    puts
  end

  def bundle_for_heroku
    run "touch .bundle_for_heroku"
    bundle
  end

  def bundle_for_deploy
    run "rm .bundle_for_heroku"
    bundle
  end

  def bundle
    run "rm Gemfile.lock"
    run "bundle install --quiet"
  end

  def rebuild_database
    puts "*** Deploying database to Heroku ***"
    run "heroku db:reset            --app #{app_name}"
    run "heroku rake db:migrate     --app #{app_name}"
    run "heroku rake db:seed        --app #{app_name}"
    run "heroku rake db:repopulate  --app #{app_name}"
    puts
  end

  def migrate_database
    run "heroku rake db:migrate --app #{app_name}"
    puts
  end

  def finish
    puts
    # Make doubly-sure this folder is back to the pre-deploy state
    run "darcs revert -a"
    puts

    puts "***********"
    puts "*  Done!  *"
    puts "***********"
  end

  desc "Deploy code"
  task :code do
    clean_up
    deploy_code
    finish
  end

  desc "Deploy and migrate DB"
  task :migrate do
    clean_up
    deploy_code
    migrate_database
    finish
  end

  desc "Deploy and reset DB"
  task :rebuild do
    clean_up
    deploy_code
    rebuild_database
    finish
  end
end
