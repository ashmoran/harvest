Feature: Fishing over multiple years
  Background:
    Given a Fishing Ground "The Atlantic Ocean" has been opened in year 2012
    And the following Fishermen have set up in business in "The Atlantic Ocean":
      | Name              |
      | Captain Birdseye  |
      | Captain Jesus     |
      | J R Hartley       |
    And fishing has started in "The Atlantic Ocean"

    And the Fishermen in "The Atlantic Ocean" sent their boats out with the following orders:
      | Fishing business  | Order |
      | Captain Birdseye  | 10    |
      | Captain Jesus     | 10    |
      | J R Hartley       | 20    |
    And the year ended in "The Atlantic Ocean"

  Scenario: Catch all the fish in the first year
    When the Fishermen in "The Atlantic Ocean" send their boats out with the following orders:
      | Fishing business  | Order |
      | Captain Birdseye  | 1     |
      | Captain Jesus     | 1     |
      | J R Hartley       | 1     |
    And the year ends in "The Atlantic Ocean"

    Then Fishermen in "The Atlantic Ocean" see the following business statistics:
      | Fishing business  | Lifetime fish caught  | Lifetime profit |
      | Captain Birdseye  | 10                    | $50             |
      | Captain Jesus     | 10                    | $50             |
      | J R Hartley       | 20                    | $100            |
