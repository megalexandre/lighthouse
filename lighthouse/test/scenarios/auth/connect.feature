Feature: Connect

  On a first start the app asks for the server's address. A Jellyfin
  server there leads to its login screen; anything else says why, and the
  user stays on the connect screen.

  Background:
    Given the app is started for the first time

  Scenario: A first start asks for the server's address
    Then I see the connect screen with an empty address

  Scenario: A working server leads to its login screen
    When I connect to {'http://jellyfin.test:8096'}
    Then I see the login screen of {'Test Server'}

  Scenario: Pressing Enter connects too
    When I type the address {'http://jellyfin.test:8096'} and press Enter
    Then I see the login screen of {'Test Server'}

  Scenario: A server that does not answer says why
    Given nothing answers at {'http://nowhere:8096'}
    When I connect to {'http://nowhere:8096'}
    Then I see the error {'Cannot reach http://nowhere:8096. Check the address and that the server is running.'}
    And I am still on the connect screen

  Scenario: A fallback address reaches the server when the first does not answer
    Given nothing answers at {'fedora.local'}
    When I connect to {'fedora.local'} with the fallback {'jellyfin.example.com'}
    Then I see the login screen of {'Test Server'}

  Scenario: A fallback address on another server is refused
    Given another Jellyfin server answers at {'jellyfin.example.com'}
    When I connect to {'fedora.local'} with the fallback {'jellyfin.example.com'}
    Then I see the error {'jellyfin.example.com reaches a different Jellyfin server than the first address.'}
    And I am still on the connect screen

  Scenario: An empty address is not sent
    When I connect to {'  '}
    Then I see the error {'Enter the server address.'}
    And I am still on the connect screen
