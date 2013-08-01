namespace :site do
  namespace :build do
    task :lib => :'site:build:lib:all'

    namespace :lib do
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
        "web_client/www/lib/signup.min.js",
        "web_client/www/lib/vendor.min.js"
      ]

      # ===== harvest =====

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
        FileUtils.mkdir_p(File.dirname(t.name))
        FileUtils.cp(source_coffee_filename[t.name], t.name)
      end

      # ===== vendor =====

      file "web_client/www/lib/vendor.min.js" => [
        # These we put in by hand:
        "web_client/www/lib/vendor/enumerable.js",
        "web_client/www/lib/vendor/jquery.js",
        "web_client/www/lib/vendor/jquery.validate.js",
        "web_client/www/lib/vendor/jquery.validate.additional-methods.js",
        "web_client/www/lib/vendor/handlebars.js",
        "web_client/www/lib/vendor/rsvp.js",
        "web_client/www/lib/vendor/ember.js",

        # Zurb Foundation:
        "web_client/www/lib/vendor/foundation/foundation.js",

        # These came from Zurb Foundation:
        "web_client/www/lib/vendor/custom.modernizr.js",
        "web_client/www/lib/vendor/zepto.js"
      ] do |t|
        uglifyjs(
          "--compress",
          "--mangle",
          "--source-map #{File.basename(t.name).sub(".js", ".map")}",
          "-o #{File.basename(t.name)}",
          "#{relative(t.prerequisites).join(" ")}"
        )
        revert_to_legacy_sourcemap_syntax(t.name)
      end

      source_vendor_js_filename =
        ->(task_name){ task_name.sub("web_client/www/lib/vendor", "web_client/vendor/lib") }

      rule %r{^web_client/www/lib/vendor/[-\w./]+\.js$} => [
        source_vendor_js_filename
      ] do |t|
        FileUtils.mkdir_p(File.dirname(t.name))
        FileUtils.cp(source_vendor_js_filename[t.name], t.name)
      end
    end
  end
end
