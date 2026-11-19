Feature: Login

  A user signs in to the server the app is connected to. The right
  username and password open the home screen; 
  a wrong one keeps the user on the login screen and says why.

  Background:
    Given the app is connected to a server

  Scenario: The right username and password open the home screen

    When I sign in as {'alice'} with password {'secret'}
    Then I see the home screen signed in as {'alice'}

  Scenario: A wrong password shows an error
  
    When I sign in as {'alice'} with password {'wrong'}
    Then I see the error {'Wrong username or password.'}
    And I am still on the login screen
