Feature: Fishing starts

  Background:
    Given I have signed up as Fisherman "Captain Ahab"
    And someone has opened Fishing Ground "The Atlantic Ocean"
    And I have set up in business in "The Atlantic Ocean"
    And I have gone to Fishing Ground "The Atlantic Ocean"

  # We used to do this for all Fishermen, and it used to be location-unaware.
  # Now it only shows the statistics for out business.
  Scenario: Fishing starts
    When someone starts fishing in "The Atlantic Ocean"

    Then I see the following statistics for my own business:
      | Lifetime fish caught | Lifetime profit |
      | 0                    | $0              |
