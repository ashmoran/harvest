Feature: Fishing over multiple years
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

    And the Fishermen sent their boats out with the following orders:
      | Fishing business  | Order |
      | Captain Birdseye  | 10    |
      | Captain Jesus     | 10    |
      | J R Hartley       | 20    |
    And someone ended the year in Fishing Ground "The Atlantic Ocean"

  @wip
  Scenario: Catch all the fish in the first year
    When the Fishermen sent their boats out with the following orders:
      | Fishing business  | Order |
      | Captain Birdseye  | 1     |
      | Captain Jesus     | 1     |
      | J R Hartley       | 1     |
    And someone ends the year in Fishing Ground "The Atlantic Ocean"

    Then the Fishermen see the following business statistics:
      | Fishing business  | Lifetime fish caught  | Lifetime profit |
      | Captain Birdseye  | 10                    | $50             |
      | Captain Jesus     | 10                    | $50             |
      | J R Hartley       | 20                    | $100            |
