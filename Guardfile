# Fake build process for HTML
guard 'slim', slim: { pretty: true },
    input_root: 'web_client/src/pages',
    output_root: 'web_client/www/pages' do
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
  watch(%r{^app_server/spec/.+_spec\.rb})
  watch(%r{^app_server/lib/(.+)\.rb}) { |m| "app_server/spec/#{m[1]}_spec.rb" }

  watch('app_server/spec/spec_helper.rb') { "app_server/spec" }
  watch(%r{app_server/spec/support/(.+)\.rb}) { "app_server/spec" }
end

guard 'mocha-node',
  mocha_bin:  "node_modules/mocha/bin/mocha",
  require:    'web_client/spec/spec_helper',
  # I think there's a bug with this, it's either reporting failures incorrectly,
  # or maybe treating pending examples as failures, I didn't bother to find out what:
  keep_failed: false,
  paths_for_all_specs: [ "web_client/spec" ] do

  watch(%r{^web_client/spec/(.+)_spec\.coffee})

  watch(%r{^web_client/src/lib/(.+)\.(js\.coffee|js|coffee)}) { |m|
    "spec/#{m[1]}_spec.coffee"
  }
  watch(%r{web_client/spec/spec_helper\.(js|coffee)}) { "web_client/spec" }
end

guard 'process', :name => 'dev_server', :command => 'rake server' do
  # Don't reload on Slim/Sass etc changes
  watch(%r{^app_server/lib/.*\.rb$})
end
