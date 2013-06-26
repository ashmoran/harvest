namespace :dev do
  desc "Clean up temporary development files"
  task :cleanup do
    system "rm tmp/capybara/*"
  end
end