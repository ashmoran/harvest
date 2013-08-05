$LOAD_PATH.unshift(File.expand_path(Dir.pwd + "/lib"))

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
