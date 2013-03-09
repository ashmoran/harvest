Given %r/^I am a visitor$/ do
  # NOOP
end

When %r/^a Visitor goes to the Fishing Registrar's office$/ do
  client.go_to_registrars_office
end

When %r/^(?:a Visitor )?signs up as Fisherman "(.*?)"$/ do |name|
  known_aggregate_root_uuids[:fishermen][name] =
    client.sign_up_fisherman(name: name)
end

# State check!
Then %r/^the Fisherman is sitting in the Fishing Registrar's office$/ do
  expect(client.location_name).to be == :inside_registrars_office
end
