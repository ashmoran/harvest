# This file will only come back into use when we start using
# Cucumber to specify the events being fired

Transform %r/^\d+ events?$/ do |step_arg|
	/\d+/.match(step_arg)[0].to_i
end

Then %r/^there should be (\d+ events?) fired$/ do |number_of_events|
  captured_events.should have(number_of_events).elements
end