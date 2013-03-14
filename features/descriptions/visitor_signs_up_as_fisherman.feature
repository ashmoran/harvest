# TODO: Rename Visitor -> Guest?

Feature: Visitor signs up as a Fisherman
  We have to know who is playing so visitors to the game
  must sign up as a Fisherman to identify themselves

  @wip
  Scenario: Visitor signs up as a Fisherman
    When a Visitor goes to the Fishing Registrar's Office
    And signs up as Fisherman "Captain Ahab"
    Then the Fisherman is sitting in the Fishing Registrar's Office

  @wip
  Scenario: Visitor signs up as a Fisherman
    When a Visitor goes to the Fishing Registrar's Office
    And signs up as Fisherman "Captain Ahab"

    When he looks at the list of registered Fisherman
    Then 1 Fisherman is registered
    And Fisherman "Captain Ahab" is visible in the list of registered Fishermen
