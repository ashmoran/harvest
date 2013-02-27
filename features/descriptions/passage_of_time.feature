Feature: Passage of time
  Background:
    Given a Fishing Ground "The Atlantic Ocean" has been opened:
      | Starting year | Lifetime  |
      | 2012          | 3         |
    And the following Fishermen have set up in business in "The Atlantic Ocean":
      | Name              |
      | Captain Birdseye  |
    And fishing has started in "The Atlantic Ocean"

  Scenario: Initially
    Then Fishermen can see Fishing Ground "The Atlantic Ocean":
      | Starting year | Current year |
      | 2012          | 2012         |

  Scenario: Pass a few years
    When Fisherman "Captain Birdseye" twiddles his thumbs for a year in "The Atlantic Ocean"
    And the year ends in "The Atlantic Ocean"

    When Fisherman "Captain Birdseye" twiddles his thumbs for a year in "The Atlantic Ocean"
    And the year ends in "The Atlantic Ocean"

    Then Fishermen can see Fishing Ground "The Atlantic Ocean":
      | Starting year | Current year |
      | 2012          | 2014         |

  Scenario: Fish until the ground's lifetime expires
    When Fisherman "Captain Birdseye" twiddles his thumbs for a year in "The Atlantic Ocean"
    And the year ends in "The Atlantic Ocean"

    When Fisherman "Captain Birdseye" twiddles his thumbs for a year in "The Atlantic Ocean"
    And the year ends in "The Atlantic Ocean"

    When Fisherman "Captain Birdseye" twiddles his thumbs for a year in "The Atlantic Ocean"
    And the year ends in "The Atlantic Ocean"

    Then Fishermen can't see Fishing Ground "The Atlantic Ocean"