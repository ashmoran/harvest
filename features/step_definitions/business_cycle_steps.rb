Given %r/^fishing has started in "(.*?)"$/ do |fishing_ground_name|
  start_fishing(fishing_ground_name)
end

When %r/^someone (?:starts|has started) fishing in "(.*?)"$/ do |fishing_ground_name|
  someone.go_to_registrars_office
  someone.go_to_fishing_ground(known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name])
  someone.start_fishing
end

When(/^someone (?:ends|ended) the year in Fishing Ground "(.*?)"$/) do |fishing_ground_name|
  someone.go_to_fishing_ground(
    known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]
  )
  someone.end_current_year
end
