When %r/^I (?:have )?set up in business in "(.*?)"$/ do |fishing_ground_name|
  client.set_up_in_business(
    fishing_ground_uuid:  known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]
  )
end

# TODO: Replace the implementation of this with the step below
Given %r/^the following Fishermen have signed up and set up in business in "(.*?)":$/ do |fishing_ground_name, table|
  fishing_ground_uuid = known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]

  table.map_headers! { |header| header.downcase.to_sym }

  table.hashes.each do |row|
    temp_client = new_client

    temp_client.go_to_registrars_office
    temp_client.sign_up_fisherman(name: row[:name])
    temp_client.set_up_in_business(fishing_ground_uuid:  fishing_ground_uuid)
  end
end

Given(/^these Fishermen have set up in business in "(.*?)":$/) do |fishing_ground_name, table|
  fishing_ground_uuid = known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]

  table.hashes.each do |row|
    fisherman_name = row["Name"]
    # TODO: Move the construction somewhere more explicit
    client = (fisherman_clients[fisherman_name] = new_client)

    client.go_to_registrars_office
    client.sign_up_fisherman(name: fisherman_name)
    client.set_up_in_business(fishing_ground_uuid: fishing_ground_uuid)
  end
end

Then %r/^the list of Fishermen working here includes "(.*?)"$/ do |name|
  expect(
    client.fishing_ground_businesses.map { |record| record[:fishing_business_name] }
  ).to include(name)
end

When %r/^I twiddle my thumbs for a year$/ do
  client.send_boat_out_to_sea(order: 0)
end

When(/^the Fishermen (?:send|sent) their boats out with the following orders:$/) do |table|
  table.hashes.each do |row|
    fisherman_name = row["Fishing business"]
    fisherman_clients[fisherman_name].send_boat_out_to_sea(
      order: row["Order"].to_i,
    )
  end
end

Then %r/^I see the following statistics for my own business:$/ do |table|
  rows = table.hashes
  fail "Expected exactly one row, for the current business" unless rows.length == 1
  expected_values = rows.first

  expect(
    client.business_statistics[:lifetime_fish_caught].to_s
  ).to be == expected_values["Lifetime fish caught"]

  expect(
    client.business_statistics[:lifetime_profit].to_s
  ).to be == expected_values["Lifetime profit"]
end

Then(/^the Fishermen see the following business statistics:$/) do |table|
  table.hashes.each do |expected_statistics|
    fishing_business_name = expected_statistics["Fishing business"]
    client = fisherman_clients[fishing_business_name]
    statistics = client.business_statistics

    # Duplicated with "Then I see the following statistics for my own business"
    expect(statistics[:lifetime_fish_caught].to_s).to be == expected_statistics["Lifetime fish caught"]
    expect(statistics[:lifetime_profit].to_s).to be == expected_statistics["Lifetime profit"]
  end
end
