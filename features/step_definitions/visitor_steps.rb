module VisitorSteps
  def sign_up_as_fisherman(attributes)
    name = attributes[:name]

    client.go_to_registrars_office

    known_aggregate_root_uuids[:fishermen][name] =
      client.sign_up_fisherman(name: name)
  end

  # TODO: merge with above
  def register_fisherman(attributes)
    fisherman_name = attributes[:name]
    # TODO: Use a client, when we know which one
    known_aggregate_root_uuids[:fishermen][fisherman_name] = poseidon.sign_up_fisherman(name: fisherman_name)
  end
end

World(VisitorSteps)

# This has been temporarily pulled in from fisherman_steps because strictly it applies to Visitors
Given %r/^a Fisherman "(.*?)" has registered$/ do |fisherman_name|
  register_fisherman(name: fisherman_name)
end

Given %r/^I am a visitor$/ do
  # NOOP
end

When %r/^a Visitor goes to the Fishing Registrar's office$/ do
  client.go_to_registrars_office
end

Given %r/^I have signed up as Fisherman "(.*?)"$/ do |name|
  sign_up_as_fisherman(name: name)
end
When %r/^(?:a Visitor )?signs up as Fisherman "(.*?)"$/ do |name|
  sign_up_as_fisherman(name: name)
end

# State check!
Then %r/^the Fisherman is sitting in the Fishing Registrar's office$/ do
  expect(client.location_name).to be == :inside_registrars_office
end
