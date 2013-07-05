namespace :git do
  task :push do
    puts 'Running `git push`:'
    puts
    system "git push"
  end
end