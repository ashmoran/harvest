# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

require 'nutils'

# Slim::Engine.set_default_options :pretty => true
Nanoc::Filter.register '::Nanoc::Filters::SlimPretty', :slim_pretty
