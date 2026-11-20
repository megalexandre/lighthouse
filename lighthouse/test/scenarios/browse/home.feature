Feature: Home

  Home lists the libraries, then what is being watched, then the latest
  of each library, a row each. A row with nothing in it is left out; one
  that fails says so, and the others still show.

  Background:
    Given the app is signed in

  Scenario: The libraries, then the latest of each
    When I go home
    Then I see {'Movies'} in the {'My media'} row
    And I see {'Shows'} in the {'My media'} row
    And I see {'Music'} in the {'My media'} row
    And I see {'Test Movie'} in the {'Latest in Movies'} row
    And I see {'Test Show'} in the {'Latest in Shows'} row
    And I see {'Test Album'} in the {'Latest in Music'} row

  Scenario: Rows with nothing in them are left out
    When I go home
    Then there is no {'Continue watching'} row
    And there is no {'Next up'} row

  Scenario: What is being watched, and what comes next
    Given {'Test Movie'} is {40} percent watched
    And {'Episode 2'} is next up
    When I go home
    Then I see {'Test Movie'} in the {'Continue watching'} row
    And the {'Continue watching'} row shows how much is watched
    And I see {'Test Show · S1:E2'} in the {'Next up'} row

  Scenario: A row that fails says so, and the others still show
    Given the latest items cannot be loaded
    When I go home
    Then I see {'Movies'} in the {'My media'} row
    And the {'Latest in Movies'} row says {'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.'}
    When the server answers again
    And I tap Retry in the {'Latest in Movies'} row
    Then I see {'Test Movie'} in the {'Latest in Movies'} row

  Scenario: Libraries that fail to load can be tried again
    Given the list of libraries cannot be loaded
    When I go home
    Then I see {'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.'}
    When the server answers again
    And I tap Retry
    Then I see {'Movies'} in the {'My media'} row

  Scenario: A library opens as a grid, and Back returns home
    When I go home
    And I open {'Movies'}
    Then I see the {'Movies'} library
    And I see {'Test Movie'}
    And I see {'HEVC Movie'}
    When I go back
    Then I see home

  Scenario: Lanterna keeps the plain layout
    When I go home
    Then there is no bar of tabs
    And there is no carousel
    And I see {'Movies'} in the {'My media'} row
    And no row has arrows
