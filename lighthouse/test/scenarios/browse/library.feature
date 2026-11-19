Feature: Library

  A library opens as a grid of its items, a page at a time as it is
  scrolled. An empty one says so; what fails to load can be tried again.

  Background:
    Given the app is signed in

  Scenario: The library's name and its items
    When I open the {'Movies'} library
    Then I see the {'Movies'} library
    And I see {'Test Movie'}
    And I see {'2020'}
    And I see {'HEVC Movie'}

  Scenario: Scrolling to the end brings every item
    Given there are {250} movies
    When I open the {'Movies'} library
    Then I do not see {'Movie 249'}
    When I scroll to the end
    Then I see {'Movie 249'}
    And nothing is loading

  Scenario: A page that fails to load can be tried again
    Given there are {150} movies
    When I open the {'Movies'} library
    And the library cannot be loaded
    And I scroll to the end
    Then I do not see {'Movie 149'}
    When the server answers again
    And I tap Retry
    And I scroll to the end
    Then I see {'Movie 149'}

  Scenario: An empty library says so
    Given there are {0} movies
    When I open the {'Movies'} library
    Then I see {'Nothing here yet.'}

  Scenario: A library that fails to open can be tried again
    Given the library cannot be loaded
    When I open the {'Movies'} library
    Then I see {'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.'}
    When the server answers again
    And I tap Retry
    Then I see {'Test Movie'}

  Scenario: A movie opens its page
    When I open the {'Movies'} library
    And I open {'Test Movie'}
    Then I see the page of {'Test Movie'}
