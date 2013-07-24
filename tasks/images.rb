namespace :images do
  desc "Import images"
  task :import do
    # Could do with being recursive, and also we probably want
    # to avoid trampling any images from vendor/ (or vice versa)
    # somehaw
    Dir.glob("web_client/src/images/*").each do |file|
      FileUtils.cp(file, "web_client/www/images")
    end
  end
end