@wip
Feature: Passage of time
  Background:
    Given I have signed up as Fisherman "Captain Birdseye"
    And someone has opened Fishing Ground "The Atlantic Ocean":
      | Starting year | Lifetime  |
      | 2012          | 3         |
    And I have set up in business in "The Atlantic Ocean"
    And someone has started fishing in "The Atlantic Ocean"

  Scenario: Initially
    When I go to the Fishing Registrar's Office
    Then I can see Fishing Ground "The Atlantic Ocean":
      | Starting year | Current year |
      | 2012          | 2012         |

  Scenario: Pass a few years
    Given I have gone to Fishing Ground "The Atlantic Ocean"

    When I twiddle my thumbs for a year
    And someone ends the year in Fishing Ground "The Atlantic Ocean"
    And I twiddle my thumbs for a year
    And someone ends the year in Fishing Ground "The Atlantic Ocean"
    And I go to the Fishing Registrar's Office

    Then I can see Fishing Ground "The Atlantic Ocean":
      | Starting year | Current year |
      | 2012          | 2014         |

  Scenario: Fish until the ground's lifetime expires
    Given I have gone to Fishing Ground "The Atlantic Ocean"

    When I twiddle my thumbs for a year
    And someone ends the year in Fishing Ground "The Atlantic Ocean"
    And I twiddle my thumbs for a year
    And someone ends the year in Fishing Ground "The Atlantic Ocean"
    And I twiddle my thumbs for a year
    And someone ends the year in Fishing Ground "The Atlantic Ocean"
    And I go to the Fishing Registrar's Office

    Then I can't see Fishing Ground "The Atlantic Ocean"