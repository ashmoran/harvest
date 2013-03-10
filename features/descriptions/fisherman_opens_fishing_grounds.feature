Feature: Fisherman opens fishing grounds
  Games (fishing grounds) are opened by Fishermen

  Background:
    Given I have signed up as Fisherman "Captain Ahab"

  @wip
  Scenario: Fishing ground
    When someone opens a Fishing Ground "The North Sea" in year 2012
    Then 1 Fishing Ground is available to join
    # TODO: make this step more personal?
    And Fishermen can see Fishing Ground "The North Sea":
      | Starting year | Current year |
      | 2012          | 2012         |
