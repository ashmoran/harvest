# TODO: Rename Visitor -> Guest?
Feature: Visitor signs up as a Fisherman
  We have to know who is playing so visitors to the game
  must sign up as a Fisherman to identify themselves

  Scenario: Visitor signs up as a Fisherman
    When a Visitor goes to the Fishing Registrar's Office
    And signs up as Fisherman "Captain Ahab"
    Then the Fisherman is sitting in the Fishing Registrar's Office

  Scenario: Visitor signs up as a Fisherman
    When a Visitor goes to the Fishing Registrar's Office
    And signs up as Fisherman "Captain Ahab"

    Then he sees 1 Fisherman is registered
    And Fisherman "Captain Ahab" is in the list of registered Fishermen
