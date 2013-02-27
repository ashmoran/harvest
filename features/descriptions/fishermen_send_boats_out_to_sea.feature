Feature: Fishermen send boats out to sea
  Background:
    Given a Fishing Ground "The Atlantic Ocean" has been opened in year 2012
    And the following Fishermen have set up in business in "The Atlantic Ocean":
      | Name              |
      | Captain Birdseye  |
      | Captain Jesus     |
      | J R Hartley       |
    And fishing has started in "The Atlantic Ocean"

  Scenario: Everybody catches something
    When the Fishermen in "The Atlantic Ocean" send their boats out with the following orders:
      | Fishing business  | Order |
      | Captain Birdseye  | 5     |
      | Captain Jesus     | 10    |
      | J R Hartley       | 15    |
    And the year ends in "The Atlantic Ocean"

    Then Fishermen in "The Atlantic Ocean" see the following business statistics:
      | Fishing business  | Lifetime fish caught  | Lifetime profit |
      | Captain Birdseye  | 5                     | $25             |
      | Captain Jesus     | 10                    | $50             |
      | J R Hartley       | 15                    | $75             |

  Scenario: A fisherman is greedy
    When the Fishermen in "The Atlantic Ocean" send their boats out with the following orders:
      | Fishing business  | Order |
      | Captain Birdseye  | 5     |
      | Captain Jesus     | 10    |
      | J R Hartley       | 100   |
    And the year ends in "The Atlantic Ocean"

    Then Fishermen in "The Atlantic Ocean" see the following business statistics:
      | Fishing business  | Lifetime fish caught  | Lifetime profit |
      | Captain Birdseye  | 5                     | $25             |
      | Captain Jesus     | 10                    | $50             |
      | J R Hartley       | 0                     | $0              |
