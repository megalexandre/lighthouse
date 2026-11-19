Feature: Search

  The search button or Ctrl+F opens search. Results come in rows by kind,
  and one opens its page. A search that fails can be tried again.

  Background:
    Given the app is signed in

  Scenario: The search button opens search
    Given I am on the home screen
    When I tap the search button
    Then I see the search screen

  Scenario: Ctrl+F opens search
    Given I am on the home screen
    When I press Ctrl+F
    Then I see the search screen

  Scenario: Results come in rows by kind
    Given I am on the search screen
    When I search for {'test'}
    Then I see {'Test Movie'} among the {'Movies'}
    And I see {'Test Show'} among the {'Shows'}
    And I see {'Test Album'} among the {'Albums'}
    And there is no {'Songs'} row

  Scenario: A search that finds nothing says so
    Given I am on the search screen
    When I search for {'zzz'}
    Then I see {'Nothing found for "zzz".'}

  Scenario: A result opens its page
    Given I am on the search screen
    When I search for {'movie'}
    And I open {'Test Movie'}
    Then I see the page of {'Test Movie'}

  Scenario: A search that fails can be tried again
    Given the server cannot be reached
    And I am on the search screen
    When I search for {'test'}
    Then I see {'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.'}
    When the server answers again
    And I tap Retry
    Then I see {'Test Movie'} among the {'Movies'}
