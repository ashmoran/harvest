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

When %r/^fishing starts in "(.*?)"$/ do |fishing_ground_name|
  start_fishing(fishing_ground_name)
end

When %r/^the year (?:ends|ended) in "(.*?)"$/ do |fishing_ground_name|
  fishing_ground_uuid = known_aggregate_root_uuids[:fishing_grounds][fishing_ground_name]
  poseidon.end_year_in_fishing_ground(uuid: fishing_ground_uuid)
end