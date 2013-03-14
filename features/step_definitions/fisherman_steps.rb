Then %r/^he sees (\d+) (?:Fisherman is|Fishermen are) registered$/ do |expected_number|
  expect(client.registered_fishermen.count).to be == expected_number.to_i
end

Then %r/^Fisherman "(.*?)" is in the list of registered Fishermen$/ do |expected_name|
  expect(
    client.registered_fishermen.map { |record| record[:name] }
  ).to include(expected_name)
end
