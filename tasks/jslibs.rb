namespace :jslibs do
  desc "Import third-party JavaScript libraries"
  task :import do
    FileUtils.mkdir_p("web_client/www/lib/vendor")
    Dir.glob("web_client/vendor/lib/*").each do |file|
      FileUtils.cp(file, "web_client/www/lib/vendor/")
    end
  end

  namespace :build do
    def coffee(*args)
      node_command_in_www_lib("coffee-script/bin/coffee", args)
    end

    def mapcat(*args)
      node_command_in_www_lib("mapcat/bin/mapcat", args)
    end

    def uglifyjs(*args)
      node_command_in_www_lib("uglify-js/bin/uglifyjs", args)
    end

    def node_command_in_www_lib(command, args)
      command = [
        "cd web_client/www/lib;",
        "#{PROJECT_DIR}/node_modules/#{command}"
      ].concat(
        args
      ).join(" ")

      system(command)
    end

    def relative(prerequisites)
      prerequisites.map { |prerequisite|
        prerequisite.sub("web_client/www/lib/", "")
      }
    end

    # Chrome 28 only understands //@ syntax, Chrome 29 will understand //#
    def revert_to_legacy_sourcemap_syntax(file)
      system "sed -E -i '' '/^\\/\\/#/s/^\\/\\/#/\\/\\/@/' #{file}"
    end

    desc "Build all JavaScript files"
    task :all => [
      "web_client/www/lib/harvest",
      "web_client/www/lib/signup.min.js",
      "web_client/www/lib/vendor",
      "web_client/www/lib/vendor.min.js"
    ]

    # ===== lib/harvest/

    file "web_client/www/lib/signup.min.js" => [
      "web_client/www/lib/harvest/signup.js"
    ] do |t|
      uglifyjs(
        "--compress",
        "--mangle",
        "--source-map #{File.basename(t.name).sub(".js", ".map")}",
        # UglifyJS only supports one input map currently
        # Note that we have to put signup.map in the root so that mapcat
        # infers the correct relative harvest/ path
        "--in-source-map signup.map",
        "-o #{File.basename(t.name)}",
        "harvest/signup.js"
      )
      revert_to_legacy_sourcemap_syntax(t.name)
    end

    file "web_client/www/lib/harvest/signup.js" => [
      "web_client/www/lib/harvest/signup_form.js",
      "web_client/www/lib/harvest/calm_delegate.js",
      "web_client/www/lib/harvest/signup_service.js"
    ] do |t|
      mapcat(
        "-j harvest/#{File.basename(t.name)}",
        "-m #{File.basename(t.name).sub(".js", ".map")}",
        # mapcat works off the source maps, not the source files themselves
        "#{relative(t.prerequisites).map { |js| js.sub(".js", ".map") }.join(" ")}"
      )
      revert_to_legacy_sourcemap_syntax(t.name)
    end

    %w[ signup_form signup_service calm_delegate ].each do |coffescript_file|
      file "web_client/www/lib/harvest/#{coffescript_file}.js" => [
        "web_client/www/lib/harvest/#{coffescript_file}.coffee",
      ] do |t|
        coffee(
          "--compile",
          "--map #{relative(t.prerequisites).join(" ")}"
        )
      end
    end

    source_coffee_filename =
      ->(task_name){ task_name.sub("web_client/www/lib", "web_client/src/lib") }

    rule %r{^web_client/www/lib/[\w/]+/\w+\.coffee$} => [
      source_coffee_filename
    ] do |t|
      FileUtils.cp(source_coffee_filename[t.name], t.name)
    end

    directory "web_client/www/lib/harvest"

    # ===== lib/vendor/

    file "web_client/www/lib/vendor.min.js" => [
      "web_client/www/lib/vendor/enumerable.js",
      "web_client/www/lib/vendor/jquery.js",
      "web_client/www/lib/vendor/jquery.validate.js",
      "web_client/www/lib/vendor/jquery.validate.additional-methods.js",
      "web_client/www/lib/vendor/handlebars.js",
      "web_client/www/lib/vendor/rsvp.js",
      "web_client/www/lib/vendor/ember.js"
    ] do |t|
        uglifyjs(
          "--compress",
          "--mangle",
          "--source-map vendor.min.map",
          "-o #{File.basename(t.name)}",
          "#{relative(t.prerequisites).join(" ")}"
        )
      revert_to_legacy_sourcemap_syntax(t.name)
    end

    source_javascript_filename =
      ->(task_name){ task_name.sub("web_client/www/lib/vendor", "web_client/vendor/lib") }

    # Generic rule for JavaScript files, but currently only applies to vendor libs
    # as all our own source is in CoffeeScript
    rule %r{^web_client/www/lib/vendor/[-\w.]+\.js$} => [
      source_javascript_filename
    ] do |t|
      FileUtils.cp(source_javascript_filename[t.name], t.name)
    end

    directory "web_client/www/lib/vendor"
  end
end
