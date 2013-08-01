$LOAD_PATH.unshift(File.expand_path(Dir.pwd + "/lib"))

guard 'nanoc', dir: "web_client" do
  watch('web_client/nanoc.yaml') # Change this to config.yaml if you use the old config file name
  watch('web_client/Rules')
  watch(%r{^web_client/(lib|src)/.*$})
end

guard 'rake', task: 'site:build:lib' do
  watch(%r{^web_client/src/lib/(.+)\.coffee$})
  watch(%r{^web_client/vendor/lib/(.+)\.js$})
end

guard 'process', name: 'dev_server', command: 'rake server' do
  watch(%r{^app_server/lib/})
end

guard 'cucumber', cli: "-p guard" do
  watch('config/cucumber.yml') { 'features' }
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$}) { 'features' }
  watch(%r{^features/step_definitions/.+$}) { 'features' }
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
  paths_for_all_specs: [ "web_client/spec" ],
  reporter: "progress" do

  watch(%r{^web_client/spec/(.+)_spec\.coffee})

  watch(%r{^web_client/src/lib/(.+)\.(js\.coffee|js|coffee)}) { |m|
    "spec/#{m[1]}_spec.coffee"
  }
  watch(%r{web_client/spec/spec_helper\.(js|coffee)}) { "web_client/spec" }
end
