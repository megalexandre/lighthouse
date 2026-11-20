Feature: Connection
  The real app loses its server (a proxy in between is taken down) and
  gets it back: the banner shows, then goes, and the screen loads by
  itself.

  Scenario: The banner while the server is away; back, the grid loads by itself
    Given I am signed in as a new user through a proxy
    When the server goes away
    And I tap the {'Movies'} library
    Then I see the connection banner
    And the library does not show {'Test Movie (2020)'}
    When the server is back
    Then the library shows {'Test Movie (2020)'}
    And the connection banner is gone
