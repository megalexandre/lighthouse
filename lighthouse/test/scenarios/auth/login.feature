Feature: Login

  A user signs in to the server the app is connected to. The right
  username and password open the home screen, and stay signed in across
  restarts; a wrong one keeps the user on the login screen and says why.
  Signing out comes back to the same server; changing server forgets it.

  Background:
    Given the app is connected to a server

  Scenario: A stored server opens on its login screen
    Then I see the login screen of {'Test Server · http://jellyfin.test:8096'}

  Scenario: The right username and password open the home screen
    When I sign in as {'alice'} with password {'secret'}
    Then I see the home screen signed in as {'alice'}

  Scenario: A wrong password shows an error
    When I sign in as {'alice'} with password {'wrong'}
    Then I see the error {'Wrong username or password.'}
    And I am still on the login screen

  Scenario: A blank username is not sent
    When I sign in as {'  '} with password {'secret'}
    Then I see the error {'Enter your username.'}
    And I am still on the login screen

  Scenario: The keyboard alone signs in
    When I type the username {'alice'} and press Enter
    Then the password field has the focus
    When I type the password {'secret'} and press Enter
    Then I see the home screen signed in as {'alice'}

  Scenario: The password is hidden
    When I type the password {'secret'}
    Then the password is hidden

  Scenario: Once signed in, a restart opens home
    When I sign in as {'alice'} with password {'secret'}
    And I restart the app
    Then I see the home screen signed in as {'alice'}

  Scenario: Signing out comes back to the same server
    When I sign in as {'alice'} with password {'secret'}
    And I sign out
    Then I see the login screen of {'Test Server'}
    And I see the notice {'You signed out.'}
    And the server is told I signed out

  Scenario: Signing out does not wait for the server
    Given the server is slow to answer a sign-out
    When I sign in as {'alice'} with password {'secret'}
    And I sign out
    Then I see the login screen of {'Test Server'}
    And I see the notice {'You signed out.'}

  Scenario: The sign-out notice gives way to an error
    When I sign in as {'alice'} with password {'secret'}
    And I sign out
    And I sign in as {'alice'} with password {'wrong'}
    Then I see the error {'Wrong username or password.'}
    And I see no notice

  Scenario: Changing server forgets this one
    When I change server
    Then I see the connect screen with an empty address
    When I restart the app
    Then I see the connect screen with an empty address
