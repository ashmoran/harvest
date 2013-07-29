require 'slim'

namespace :pages do
  desc "Build static HTML pages"
  task :build do
    FileUtils.mkdir_p("web_client/www/pages")

    # Could do with being recursive
    Dir.glob("web_client/src/pages/*").each do |source_filename|
      base_filename = File.basename(source_filename, ".slim")

      rendered_html = Slim::Template.new(source_filename, pretty: true).render

      File.open("web_client/www/pages/#{base_filename}.html", "w") do |file|
        file << rendered_html
      end
    end
  end
end