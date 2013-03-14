Feature: Fisherman sets up in business in Fishing Ground
  You have to be in a Fishing Ground in order to play

  Background:
    Given I have signed up as Fisherman "Captain Ahab"
    And someone has opened Fishing Ground "The Atlantic Ocean"

  Scenario: Fisherman sets up in business
    When I set up in business in "The Atlantic Ocean"
    And I go to Fishing Ground "The Atlantic Ocean"
    Then I am at Fishing Ground "The Atlantic Ocean"
    And the list of Fishermen working here includes "Captain Ahab"