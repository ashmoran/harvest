Feature: Visitor signs up as a Fisherman
  We have to know who is playing so visitors to the game
  must sign up as a Fisherman to identify themselves

  Scenario: Visitor signs up as a Fisherman
    When a Visitor signs up as Fisherman "Captain Ahab"
    Then 1 Fisherman is registered
    And Fisherman "Captain Ahab" is visible in the list of registered Fishermen
