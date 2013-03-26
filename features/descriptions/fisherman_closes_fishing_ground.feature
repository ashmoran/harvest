@wip
Feature: Fisherman closes fishing ground
  Fishing grounds can be closed if a Fisherman decides to abandon the game

  Background:
    Given I have signed up as Fisherman "Captain Ahab"

  Scenario: Close an open Fishing Ground
    Given someone has opened Fishing Ground "The Pacific Ocean"
    And someone has opened Fishing Ground "The North Sea"

    When I close Fishing Ground "The North Sea"

    Then 1 Fishing Ground is available to join
    And I can see Fishing Ground "The Pacific Ocean"
    And I can't see Fishing Ground "The North Sea"



