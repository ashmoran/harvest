namespace :jslibs do
  desc "Import third-party JavaScript libraries"
  task :import do
    FileUtils.mkdir_p("web_client/www/lib/vendor")
    Dir.glob("web_client/vendor/lib/*").each do |file|
      FileUtils.cp(file, "web_client/www/lib/vendor/")
    end
  end
end