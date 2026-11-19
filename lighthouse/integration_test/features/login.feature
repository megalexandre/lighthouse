Feature: Login
  The real app against the test server: each scenario gets a new user,
  connects to the server, and signs in. A wrong password keeps the user on
  the login screen; signing out, here or anywhere else, ends the session.

  Background:
    Given a new user with password {'pw-123'}
    And the app is connected to the test server

  Scenario: The right password opens home, and a restart stays signed in
    When I sign in with password {'pw-123'}
    Then I see the home screen signed in as the new user
    When I restart the app
    Then I see the home screen signed in as the new user

  Scenario: A wrong password shows an error
    When I sign in with password {'wrong'}
    Then I see the error {'Wrong username or password.'}
    And I am on the login screen

  Scenario: Signing out ends the session on the server
    When I sign in with password {'pw-123'}
    And I sign out
    Then I am on the login screen
    And the server no longer accepts the old session

  Scenario: A session ended elsewhere asks to sign in again
    When I sign in with password {'pw-123'}
    And the session is ended on the server while the app is closed
    And I restart the app
    Then I am on the login screen
