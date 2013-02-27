Feature: Fisherman sets up in business in Fishing Ground
  You have to be in a Fishing Ground in order to play

  Scenario: Fisherman joins
    Given a Fisherman "Captain Ahab" has registered
    And a Fishing Ground "The Atlantic Ocean" has been opened

    When Fisherman "Captain Ahab" sets up in business in "The Atlantic Ocean"

    Then the list of Fishermen working in "The Atlantic Ocean" includes "Captain Ahab"