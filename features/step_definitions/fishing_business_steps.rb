When %r/^I (?:have )?set up in business in "(.*?)"$/ do |fishing_ground_name|
  client.set_up_in_business(
    fishing_ground_uuid:  known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]
  )
end
When %r/^Fisherman "(.*?)" sets up in business in "(.*?)"$/ do |fisherman_name, fishing_ground_name|
  poseidon.set_fisherman_up_in_business(
    fisherman_uuid:       known_aggregate_root_uuids[:fishermen][fisherman_name],
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

Given %r/^the following Fishermen have set up in business in "(.*?)":$/ do |fishing_ground_name, table|
  fishing_ground_uuid = known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]

  table.map_headers! { |header| header.downcase.to_sym }

  table.hashes.each do |row|
    fisherman_uuid = register_fisherman(name: row[:name])

    poseidon.set_fisherman_up_in_business(
      fisherman_uuid:       fisherman_uuid,
      fishing_ground_uuid:  fishing_ground_uuid
    )
  end
end

Then %r/^the list of Fishermen working here includes "(.*?)"$/ do |name|
  expect(
    client.fishing_ground_businesses.map { |record| record[:fishing_business_name] }
  ).to include(name)
end

When %r/^Fisherman "(.*?)" twiddles his thumbs for a year in "(.*?)"$/ do |business_name, fishing_ground_name|
  # Duplication with the step below
  fishing_ground_uuid = known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]
  businesses          = read_models[:fishing_ground_businesses].records_for(fishing_ground_uuid)

  business_uuid =
    businesses.detect { |business|
      business[:fishing_business_name] == business_name
    }[:fishing_business_uuid]

  poseidon.send_boat_out_to_sea(
    fishing_ground_uuid:    fishing_ground_uuid,
    fishing_business_uuid:  business_uuid,
    order:                  0
  )
end

When(/^the Fishermen (?:send|sent) their boats out with the following orders:$/) do |table|
  table.hashes.each do |row|
    fisherman_name = row["Fishing business"]
    fisherman_clients[fisherman_name].send_boat_out_to_sea(
      order: row["Order"].to_i,
    )
  end
end
When %r/^the Fishermen in "(.*?)" (?:send|sent) their boats out with the following orders:$/ do |fishing_ground_name, table|
  table.map_headers!(
    "Fishing business"  => :fishing_business_name,
    "Order"             => :order
  )

  fishing_ground_uuid = known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]
  businesses          = read_models[:fishing_ground_businesses].records_for(fishing_ground_uuid)

  table.hashes.each do |row|
    business_uuid =
      businesses.detect { |business|
        business[:fishing_business_name] == row[:fishing_business_name]
      }[:fishing_business_uuid]

    # The call to #to_i below is the clue that we need
    # more advanced type handling in the Event system
    poseidon.send_boat_out_to_sea(
      fishing_ground_uuid:    fishing_ground_uuid,
      fishing_business_uuid:  business_uuid,
      order:                  row[:order].to_i
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

# This is hideous - the step below is much better (different table orientation)
Then %r/^all Fishermen in "(.*?)" see the following business statistics:$/ do |fishing_ground_name, statistics_table|
  statistics_table.map_headers! { |header| header.downcase.to_sym }

  statistic_mappings = {
    "Lifetime fish caught"  => :lifetime_fish_caught,
    "Lifetime profit"       => :lifetime_profit
  }

  fishing_ground_uuid = known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]
  businesses = read_models[:fishing_ground_businesses].records_for(fishing_ground_uuid)

  businesses.each do |business|
    fishing_business_statistics = read_models[:fishing_business_statistics]
    business_uuid = business[:fishing_business_uuid]

    business_statistics =
      fishing_business_statistics.record_for(
        fishing_ground_uuid: fishing_ground_uuid,
        fishing_business_uuid: business_uuid
      )

    statistics_table.hashes.each do |row|
      statistic_name = statistic_mappings[row[:statistic]]
      expected_value = row[:value]

      expect(business_statistics[statistic_name].to_s).to be == expected_value
    end
  end
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
Then %r/^Fishermen in "(.*?)" see the following business statistics:$/ do |fishing_ground_name, table|
  table.map_headers!(
    {
      "Fishing business"      => :fishing_business_name,
      "Lifetime fish caught"  => :lifetime_fish_caught,
      "Lifetime profit"       => :lifetime_profit
    }.slice(*table.headers)
  )

  fishing_ground_uuid = known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]
  businesses          = read_models[:fishing_ground_businesses].records_for(fishing_ground_uuid)
  business_statistics = read_models[:fishing_business_statistics]

  table.hashes.each do |row|
    business_uuid =
      businesses.detect { |business|
        business[:fishing_business_name] == row[:fishing_business_name]
      }[:fishing_business_uuid]

    statistics =
      business_statistics.record_for(
        fishing_ground_uuid: fishing_ground_uuid,
        fishing_business_uuid: business_uuid
      )

    expect(statistics[:lifetime_fish_caught]).to be == row[:lifetime_fish_caught].to_i
    expect(statistics[:lifetime_profit].to_s).to be == row[:lifetime_profit]
  end
end