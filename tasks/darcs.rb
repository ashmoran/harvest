require_relative 'git_helpers'

namespace :darcs do
  include GitHelpers

  task :push do
    puts 'Running `darcs push`:'
    puts
    system "darcs push"
  end

  namespace :amend_record do
    desc "darcs amend-record Harvest files"
    task :harvest do
      system "darcs amend-record -a lib/harvest spec/harvest"
    end

    desc "darcs amend-record Realm files"
    task :realm do
      system "darcs amend-record -a lib/realm spec/realm"
    end
  end

  desc 'darcs pre-`record` hook'
  task :post_record do
    puts "\ndarcs:post_record output:"
    create_git_commit
  end

  desc 'darcs pre-`amend-record` hook'
  task :post_amend_record do
    puts "\ndarcs:post_amend_record output:"
    create_git_commit("Amend: ")
  end
end

desc "Alias: darcs:amend_record:harvest"
task :dah => :"darcs:amend_record:harvest"

desc "Alias: darcs:amend_record:realm"
task :dac => :"darcs:amend_record:realm"
