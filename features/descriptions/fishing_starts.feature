Feature: Fishing starts

  Scenario: Fishing starts
    Given a Fishing Ground "The Atlantic Ocean" has been opened in year 2012
    And the following Fishermen have set up in business in "The Atlantic Ocean":
      | Name              |
      | Captain Zebadee   |
      | Captain Birdseye  |

    When fishing starts in "The Atlantic Ocean"

    Then all Fishermen in "The Atlantic Ocean" see the following business statistics:
      | Statistic             | Value |
      | Lifetime fish caught  | 0     |
      | Lifetime profit       | $0    |
