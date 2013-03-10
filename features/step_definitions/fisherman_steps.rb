module FishermanSteps
  def register_fisherman(attributes)
    fisherman_name = attributes[:name]
    known_aggregate_root_uuids[:fishermen][fisherman_name] = poseidon.sign_up_fisherman(name: fisherman_name)
  end
end

World(FishermanSteps)

Given %r/^a Fisherman "(.*?)" has registered$/ do |fisherman_name|
  register_fisherman(name: fisherman_name)
end

When(/^he looks at the list of registered Fisherman$/) do
  # NOOP
  # Left in as a reminder: I think steps like this will be used
  # only when we have to make a state transition (request a new
  # resource), but currently we're embedding the fishermen
end

Then %r/^(\d+) (?:Fisherman is|Fishermen are) registered$/ do |expected_number|
  expect(client.registered_fishermen.count).to be == expected_number.to_i
end

Then %r/^Fisherman "(.*?)" is visible in the list of registered Fishermen$/ do |expected_name|
  expect(
    client.registered_fishermen.map { |record| record[:name] }
  ).to include(expected_name)
end
