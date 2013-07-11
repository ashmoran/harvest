# Fake build process for HTML
guard 'slim', slim: { pretty: true },
    input_root: 'web_client/src/pages',
    output_root: 'web_client/site/pages' do
  watch(%r'^.+\.slim$')
end

guard 'cucumber', cli: "-p guard" do
  watch('config/cucumber.yml') { 'features' }
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$}) { 'features' }
  watch(%r{^features/step_definitions/.+$}) { 'features' }

  # Temporary matcher while I hack at an HTTP interface
  # Don't need to keep running these ATM... uncomment at will
  # watch(%r{^lib/harvest/clients/harvest_http_client}) { 'features' }
  # watch(%r{^lib/harvest/http}) { 'features' }
end

# Currently including app_server/spec so rspec can find spec_helper
guard 'rspec', spec_paths: "app_server/spec", cli: "-I app_server/spec --color --format Fuubar" do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
end

guard 'mocha-node',
  mocha_bin: "node_modules/mocha/bin/mocha",
  require: 'web_client/spec/spec_helper',
  paths_for_all_specs: [ "web_client/spec" ] do

  watch(%r{^web_client/spec/(.+)_spec\.coffee}) { |m|
    "web_client/spec/#{m[1]}_spec.#{m[2]}"
  }
  watch(%r{^web_client/src/lib/(.+)\.(js\.coffee|js|coffee)}) { |m|
    "spec/#{m[1]}_spec.coffee"
  }
  watch(%r{web_client/spec/spec_helper\.(js|coffee)}) { "web_client/spec" }
end

guard 'process', :name => 'dev_server', :command => 'rake server' do
  # Don't reload on Slim/Sass etc changes
  watch(%r{^app_server/lib/.*\.rb$})
end
