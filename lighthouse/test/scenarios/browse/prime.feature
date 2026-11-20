Feature: Prime layout

  The Prime theme floats a bar over the screens, with a tab per library, a
  search field and a profile menu, and opens home with a carousel: a movie
  plays from it, a series not started opens its episodes, and one already
  started plays on from its next episode. Long rows page with arrows. Lanterna keeps its plain layout (home.feature).

  Background:
    Given the app is signed in
    And the theme is {'Prime'}

  Scenario: Home has a tab per library and the carousel, no libraries row
    When I go home
    Then there is a tab for each library
    And there is no {'My media'} row
    And the carousel shows {'Test Movie'}
    And the bar is see-through
    And no library tab is on

  Scenario: The carousel moves by its arrows, its dots, and by itself
    When I go home
    And I tap the {'next'} arrow of the carousel
    Then the carousel shows {'HEVC Movie'}
    When I tap the {'previous'} arrow of the carousel
    Then the carousel shows {'Test Movie'}
    When I tap the dot {3} of the carousel
    Then the carousel shows {'Test Show'}
    And the carousel offers {'Episodes'}
    When I wait for the carousel to move on
    Then the carousel shows {'Test Movie'}

  Scenario: A series already started plays on from its next episode
    Given {'Test Show'} was started, with {'Episode 2'} next
    When I go home
    And I tap the dot {3} of the carousel
    Then the carousel offers {'Play S1:E2'}
    When I tap the {'play'} button of the carousel
    Then {'Episode 2'} is playing from {0} seconds

  Scenario: An episode left partway plays on from where it was left
    Given {'Episode 1'} was left at {30} seconds
    When I go home
    And I tap the dot {3} of the carousel
    Then the carousel offers {'Play S1:E1'}
    When I tap the {'play'} button of the carousel
    Then {'Episode 1'} is playing from {30} seconds

  Scenario: The carousel plays a movie, or opens it
    When I go home
    And I tap the {'info'} button of the carousel
    Then I see the page of {'Test Movie'}
    When I go back
    And I tap the {'play'} button of the carousel
    Then the player is open

  Scenario: A tab opens its library under the bar, and Home comes back
    When I go home
    And I tap the {'Movies'} tab
    Then the {'Movies'} tab is on
    And the bar is solid
    And I see {'Test Movie'}
    When I tap the {'Home'} tab
    Then the carousel shows {'Test Movie'}

  Scenario: Scrolled down, the bar turns solid
    When I go home
    And I scroll home down
    Then the bar is solid

  Scenario: Search opens into a field, and Enter searches
    When I go home
    Then there is no search field
    When I search the bar for {'test'}
    Then the search screen searches for {'test'}

  Scenario: The profile menu switches the mode, opens Settings, signs out
    When I go home
    And I pick {'the other mode'} in the profile menu
    Then home is {'light'}
    When I pick {'Settings'} in the profile menu
    Then I see Settings
    When I go back
    And I pick {'Sign out'} in the profile menu
    Then I see the login screen

  Scenario: A long row pages with arrows, each only where there is more
    Given there are {24} movies
    When I go home
    And I scroll to the {'Latest in Movies'} row
    Then the {'Latest in Movies'} row has a {'next'} arrow
    And the {'Latest in Movies'} row has no {'previous'} arrow
    When I tap the {'next'} arrow of the {'Latest in Movies'} row
    Then the {'Latest in Movies'} row has a {'previous'} arrow
    When I tap the {'previous'} arrow of the {'Latest in Movies'} row
    Then the {'Latest in Movies'} row has no {'previous'} arrow
