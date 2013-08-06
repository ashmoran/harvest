require 'yaml'

module GuardCucumberConfig
  def self.reconfigure_cucumber
    config = YAML.load_file('config/cucumber_mode.yml')

    if config.fetch('wip')
      ENV['GUARD_MODE'] = 'wip'
    else
      ENV.delete('GUARD_MODE')
    end

    # We could read this from inside cucumber, but then it'd couple
    # the cucumber run to one file on the filesystem (or we'd need a
    # new environment for HARVEST_CUCUMBER_MODE or whatever...)
    ENV['HARVEST_INTERFACE'] = config.fetch('harvest_interface')
  end
end

GuardCucumberConfig.reconfigure_cucumber

group :features do
  guard 'cucumber', cli: '-p guard' do
    watch('config/cucumber_mode.yml') {
      ::Guard::Dsl.reevaluate_guardfile
    }

    watch('config/cucumber.yml') { 'features' }
    watch(%r{^features/.+\.feature$})
    watch(%r{^features/support/.+$}) { 'features' }
    watch(%r{^features/step_definitions/.+$}) { 'features' }
  end
end
