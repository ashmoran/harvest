Feature: Fisherman closes fishing ground
  Fishing grounds can be closed if a Fisherman decides to abandon the game

  Scenario: Close an open Fishing Ground
    Given a Fishing Ground "The Pacific Ocean" has been opened
    And a Fishing Ground "The North Sea" has been opened

    When someone closes Fishing Ground "The North Sea"

    Then 1 Fishing Ground is available to join
    And Fishermen can see Fishing Ground "The Pacific Ocean"
    And Fishermen can't see Fishing Ground "The North Sea"



