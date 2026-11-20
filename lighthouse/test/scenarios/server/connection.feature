Feature: Connection

  When the server stops answering, a banner says so and the app tries
  again, slower and slower. When it answers, the banner goes and the
  screen loads again by itself. Retry now does not wait.

  Background:
    Given the app is signed in
    And I am on the home screen

  Scenario: A banner while the server is away; back, home loads by itself
    Then I do not see the connection banner
    When the server goes away
    Then I see the connection banner
    And I do not see the libraries
    When I wait {'1 second'}
    Then I see the connection banner
    When the server is back
    And I wait {'2 seconds'}
    Then I do not see the connection banner
    And I see the libraries

  Scenario: Retry now does not wait for the next try
    When the server goes away
    And the server is back
    And I tap Retry now
    Then I do not see the connection banner
