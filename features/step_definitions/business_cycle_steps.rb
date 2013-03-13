module BusinessCycleSteps
  def start_fishing(fishing_ground_name)
    fishing_ground_uuid = known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]
    poseidon.start_fishing(uuid: fishing_ground_uuid)
  end
end

World(BusinessCycleSteps)

Given %r/^fishing has started in "(.*?)"$/ do |fishing_ground_name|
  start_fishing(fishing_ground_name)
end

When %r/^someone (?:starts|has started) fishing in "(.*?)"$/ do |fishing_ground_name|
  someone.go_to_registrars_office
  someone.go_to_fishing_ground(known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name])
  someone.start_fishing
end

When %r/^fishing starts in "(.*?)"$/ do |fishing_ground_name|
  start_fishing(fishing_ground_name)
end

# It shouldn't be "someone", it should be automatic
When(/^someone (?:ends|ended) the year in Fishing Ground "(.*?)"$/) do |fishing_ground_name|
  someone.go_to_fishing_ground(
    known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]
  )
  someone.end_current_year
end
When %r/^the year (?:ends|ended) in "(.*?)"$/ do |fishing_ground_name|
  fishing_ground_uuid = known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]
  poseidon.end_year_in_fishing_ground(uuid: fishing_ground_uuid)
end