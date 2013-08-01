namespace :dev do
  desc "Clean up temporary development files, caches, etc"
  task :clean do
    system "rm -rf tmp/*"
    # We make Compass use the project tmp/ dir, but
    # I haven't  found the setting for nanoc yet
    system "rm -rf web_client/tmp/*"
  end
end