Feature: Fish regeneration

  Scenario: A small population of fish doubles
    Given someone has opened a Fishing Ground "The Atlantic Ocean" in year 2012
    And these Fishermen have set up in business in "The Atlantic Ocean":
      | Name              |
      | Captain Birdseye  |
    And these Fishermen have gone to Fishing Ground "The Atlantic Ocean":
      | Name              |
      | Captain Birdseye  |
    And someone has started fishing in "The Atlantic Ocean"

    And the Fishermen sent their boats out with the following orders:
      | Fishing business  | Order |
      | Captain Birdseye  | 20    |
    And someone ended the year in Fishing Ground "The Atlantic Ocean"

    When the Fishermen send their boats out with the following orders:
      | Fishing business  | Order |
      | Captain Birdseye  | 40    |
    And someone ends the year in Fishing Ground "The Atlantic Ocean"

    Then the Fishermen see the following business statistics:
      | Fishing business  | Lifetime fish caught  | Lifetime profit |
      | Captain Birdseye  | 60                    | $300            |