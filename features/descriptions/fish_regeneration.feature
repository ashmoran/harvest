Feature: Fish regeneration

  Scenario: A small population of fish doubles
    Given a Fishing Ground "The Atlantic Ocean" has been opened in year 2012
    And the following Fishermen have set up in business in "The Atlantic Ocean":
      | Name              |
      | Captain Birdseye  |
    And fishing has started in "The Atlantic Ocean"

    And the Fishermen in "The Atlantic Ocean" sent their boats out with the following orders:
      | Fishing business  | Order |
      | Captain Birdseye  | 20    |
    And the year ended in "The Atlantic Ocean"

    When the Fishermen in "The Atlantic Ocean" send their boats out with the following orders:
      | Fishing business  | Order |
      | Captain Birdseye  | 40    |
    And the year ends in "The Atlantic Ocean"

    Then Fishermen in "The Atlantic Ocean" see the following business statistics:
      | Fishing business  | Lifetime fish caught  | Lifetime profit |
      | Captain Birdseye  | 60                    | $300            |