guard 'cucumber', cli: "-p guard" do
  watch('config/cucumber.yml') { 'features' }
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$}) { 'features' }
  watch(%r{^features/step_definitions/.+$}) { 'features' }

  # Temporary matcher while I hack at an HTTP interface
  watch(%r{^lib/harvest/clients/harvest_http_client}) { 'features' }
  watch(%r{^lib/harvest/http}) { 'features' }
end

guard 'rspec', cli: "--color --format Fuubar" do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
end
