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
    raise "Eek, we now use Git to push to GitHub for Startups Manchester!"

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
