Feature: Navigation on a phone

  A phone has no room for the library tabs in the top bar: the navigation
  is a bar below (Home, Libraries, Search, Profile), with only the
  lighthouse mark above. On its side it is a rail at the left. Android's
  Back closes what is open on the page first, then leaves the page.

  Background:
    Given the app is signed in

  Scenario: A phone has a bar below and only the mark above
    Given the app runs on a {'phone'}
    When I go home
    Then the navigation is a bar below
    And the top bar shows only the mark

  Scenario: On its side, the navigation is a rail at the left
    Given the app runs on a {'phone on its side'}
    When I go home
    Then the navigation is a rail at the left
    When I tap {'Libraries'} in the navigation
    Then I see the list of libraries

  Scenario: Libraries lists them, and one opens with Libraries still on
    Given the app runs on a {'phone'}
    When I go home
    And I tap {'Libraries'} in the navigation
    Then I see the list of libraries
    When I open {'Movies'}
    Then the top bar is titled {'Movies'}
    And {'Libraries'} is on in the navigation
    When I tap {'Home'} in the navigation
    Then I see home

  Scenario: Search opens the search page
    Given the app runs on a {'phone'}
    When I go home
    And I tap {'Search'} in the navigation
    Then I see the search page

  Scenario: The profile names who is signed in, and opens Settings
    Given the app runs on a {'phone'}
    When I go home
    And I tap {'Profile'} in the navigation
    Then the profile sheet names {'alice'}
    When I tap {'Settings'} in the profile sheet
    Then I see Settings
    And the profile sheet is closed

  Scenario: Signing out from the profile sheet
    Given the app runs on a {'phone'}
    When I go home
    And I tap {'Profile'} in the navigation
    And I tap {'Sign out'} in the profile sheet
    Then I see the login screen

  Scenario: The desktop keeps the tabs in the top bar
    Given the theme is {'Prime'}
    When I go home
    Then there is no navigation bar or rail
    And there is a tab for each library

  Scenario: Back leaves a page for the one before
    Given the app runs on a {'phone'}
    When I open the page of {'Test Movie'}
    And I use the phone's Back
    Then I see home

  Scenario: Back leaves the search page opened from the bar below
    Given the app runs on a {'phone'}
    When I go home
    And I tap {'Search'} in the navigation
    And I use the phone's Back
    Then I see home

  Scenario: On a tablet on its side, Back closes the search field first
    Given the app runs on a {'tablet on its side'}
    When I go home
    And I open the search field
    And I use the phone's Back
    Then there is no search field
    And I see home
