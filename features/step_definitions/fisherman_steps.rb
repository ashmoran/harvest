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

When %r/^a Visitor signs up as Fisherman "(.*?)"$/ do |name|
  known_aggregate_root_uuids[:fishermen][name] =
    poseidon.sign_up_fisherman(name: name)
end

Then %r/^(\d+) (?:Fisherman is|Fishermen are) registered$/ do |expected_number|
  registered_fishermen = read_models[:registered_fishermen]
  expect(registered_fishermen.count).to be == expected_number.to_i
end

Then %r/^Fisherman "(.*?)" is visible in the list of registered Fishermen$/ do |expected_name|
  registered_fishermen = read_models[:registered_fishermen]

  expect(
    registered_fishermen.records.map { |record| record[:name] }
  ).to include(expected_name)
end
