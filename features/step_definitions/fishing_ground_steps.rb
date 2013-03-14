module FishingGroundSteps
  def open_fishing_ground(attributes)
    name = attributes.fetch(:name)

    known_aggregate_root_uuids[:fishing_grounds][name] =
      poseidon.open_fishing_ground(
        name:                 name,
        starting_population:  40,
        carrying_capacity:    50,
        starting_year:        attributes.fetch(:starting_year, 0),
        lifetime:             attributes.fetch(:lifetime, 10),
        order_fulfilment:     :random
      )
  end

  # Duplication with above, one of these will die with authentication
  def someone_opens_fishing_ground(attributes)
    someone.go_to_registrars_office

    name = attributes.fetch(:name)

    known_aggregate_root_uuids[:fishing_grounds][name] =
      someone.open_fishing_ground(
        name:                 name,
        starting_population:  40,
        carrying_capacity:    50,
        starting_year:        attributes.fetch(:starting_year, 0),
        lifetime:             attributes.fetch(:lifetime, 10),
        order_fulfilment:     :random
      )
  end
end

World(FishingGroundSteps)

When %r/^I (?:go|have gone) to Fishing Ground "(.*?)"$/ do |name|
  client.go_to_fishing_ground(
    known_aggregate_root_uuids[:fishing_grounds][name]
  )
end
Given(/^these Fishermen have gone to Fishing Ground "(.*?)":$/) do |name, table|
  fishing_ground_uuid = known_aggregate_root_uuids[:fishing_grounds][name]

  table.hashes.each do |row|
    fisherman_name = row["Name"]
    fisherman_clients[fisherman_name].go_to_fishing_ground(fishing_ground_uuid)
  end
end

Then %r/^I am at Fishing Ground "(.*?)"$/ do |name|
  expect(client.location_name).to be == :at_fishing_ground
  expect(client.location_details).to be == {
    fishing_ground_uuid: known_aggregate_root_uuids[:fishing_grounds][name]
  }
end

Given %r/^a Fishing Ground "(.*?)" has been opened(?: in (year \d+))?$/ do |name, year|
  open_fishing_ground(name: name, starting_year: year || 2012)
end

Given(/^someone has opened Fishing Ground "(.*?)":$/) do |name, table|
  table_attributes = table.hashes.first

  attributes = {
    name:           name,
    starting_year:  table_attributes.fetch("Starting year", 0).to_i,
    lifetime:       table_attributes.fetch("Lifetime", 10).to_i
  }

  someone_opens_fishing_ground(attributes)
end

Transform %r/^year \d+$/ do |step_arg|
  /\d+/.match(step_arg)[0].to_i
end

Given %r/^someone has opened Fishing Ground "(.*?)"$/ do |name|
  someone_opens_fishing_ground(name: name)
end
When %r/^someone (?:opens|has opened) a Fishing Ground "(.*?)" in (year \d+)$/ do |name, year|
  someone_opens_fishing_ground(name: name, starting_year: year)
end

When %r/^I close Fishing Ground "(.*?)"$/ do |fishing_ground_name|
  client.close_fishing_ground(uuid: known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name])
end

Then %r/^(\d+) Fishing Grounds? (?:is|are) available to join$/ do |number_of_fishing_grounds|
  expect(client.fishing_grounds_available_to_join.count).to be == number_of_fishing_grounds.to_i
end

Then %r/^I can see Fishing Ground "(.*?)":$/ do |name, table|
  expect(
    client.fishing_grounds_available_to_join.map { |record| record[:name] }
  ).to include(name)
end

Then %r/^I can see Fishing Ground "(.*?)"$/ do |name|
  expect(
    client.fishing_grounds_available_to_join.map { |record| record[:name] }
  ).to include(name)
end

Then(/^I can't see Fishing Ground "(.*?)"$/) do |name|
  # Maybe we should do this with UUIDs?
  expect(
    client.fishing_grounds_available_to_join.map { |record| record[:name] }
  ).to_not include(name)
end

Then %r/^Fishermen can see Fishing Ground "(.*?)"$/ do |name|
  fishing_grounds_available_to_join = read_models[:fishing_grounds_available_to_join]

  expect(
    fishing_grounds_available_to_join.records.map { |record| record[:name] }
  ).to include(name)
end

Then %r/^Fishermen can see Fishing Ground "(.*?)":$/ do |name, table|
  uuid = known_aggregate_root_uuids[:fishing_grounds][name]

  view = read_models[:fishing_grounds_available_to_join]
  record = view.record_for(uuid: uuid)

  expect(record).to_not be_nil

  expected_values = table.hashes.first

  expect(record[:starting_year]).to be == expected_values["Starting year"].to_i
  expect(record[:current_year]).to  be == expected_values["Current year"].to_i
end

Then %r/^Fishermen can't see Fishing Ground "(.*?)"$/ do |fishing_ground_name|
  fishing_grounds_available_to_join = read_models[:fishing_grounds_available_to_join]

  expect(
    fishing_grounds_available_to_join.records.map { |record| record[:name] }
  ).to_not include(fishing_ground_name)
end
