@wip
Feature: Fishermen send boats out to sea
  Background:
    Given someone has opened a Fishing Ground "The Atlantic Ocean" in year 2012
    And these Fishermen have set up in business in "The Atlantic Ocean":
      | Name              |
      | Captain Birdseye  |
      | Captain Jesus     |
      | J R Hartley       |
    # Temporary step? Seems odd to have to make this explicit. Where else would they be?
    And these Fishermen have gone to Fishing Ground "The Atlantic Ocean":
      | Name              |
      | Captain Birdseye  |
      | Captain Jesus     |
      | J R Hartley       |
    And someone has started fishing in "The Atlantic Ocean"

  Scenario: Everybody catches something
    When the Fishermen send their boats out with the following orders:
      | Fishing business  | Order |
      | Captain Birdseye  | 5     |
      | Captain Jesus     | 10    |
      | J R Hartley       | 15    |
    And someone ends the year in Fishing Ground "The Atlantic Ocean"

    Then the Fishermen see the following business statistics:
      | Fishing business  | Lifetime fish caught  | Lifetime profit |
      | Captain Birdseye  | 5                     | $25             |
      | Captain Jesus     | 10                    | $50             |
      | J R Hartley       | 15                    | $75             |

  Scenario: A fisherman is greedy
    When the Fishermen send their boats out with the following orders:
      | Fishing business  | Order |
      | Captain Birdseye  | 5     |
      | Captain Jesus     | 10    |
      | J R Hartley       | 100   |
    And someone ends the year in Fishing Ground "The Atlantic Ocean"

    Then the Fishermen see the following business statistics:
      | Fishing business  | Lifetime fish caught  | Lifetime profit |
      | Captain Birdseye  | 5                     | $25             |
      | Captain Jesus     | 10                    | $50             |
      | J R Hartley       | 0                     | $0              |
