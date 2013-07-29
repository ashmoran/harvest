namespace :jslibs do
  desc "Import third-party JavaScript libraries"
  task :import do
    FileUtils.mkdir_p("web_client/www/lib/vendor")
    Dir.glob("web_client/vendor/lib/*").each do |file|
      FileUtils.cp(file, "web_client/www/lib/vendor/")
    end
  end

  namespace :build do
    def coffee(args)
      system "cd web_client/www/lib/harvest; #{PROJECT_DIR}/node_modules/coffee-script/bin/coffee #{args}"
    end

    desc "Build all JavaScript files"
    task :all => [
      'web_client/www/lib/harvest',
      'web_client/www/lib/harvest/signup_form.js'
    ]

    file 'web_client/www/lib/harvest/signup_form.js' => [
      'web_client/www/lib/harvest/signup_form.coffee',
    ] do |t|
      relative_prerequisites = t.prerequisites.map { |prereq|
        prereq.sub("web_client/www/lib/harvest/", "")
      }
      coffee "--compile --map #{relative_prerequisites.join(" ")}"
    end

    source_coffee_filename =
      ->(task_name){ task_name.sub("web_client/www/lib", "web_client/src/lib") }

    rule %r{^web_client/www/lib/[\w/]+/\w+\.coffee$} => [
      source_coffee_filename
    ] do |t|
      FileUtils.cp(source_coffee_filename[t.name], t.name)
    end

    directory 'web_client/www/lib/harvest'
  end
end
