desc "Push to Darcs Hub and GitHub"
task :push => %i[
  darcs:push
  print_blank_line
  git:push
]

task :print_blank_line do
  puts
end