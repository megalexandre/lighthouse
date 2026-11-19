Feature: Watching
  The real app plays the Test Movie from the test server (mpv, no sound),
  and the server keeps where the user stopped and what they watched.

  Background:
    Given I am signed in as a new user

  Scenario: Leaving a movie halfway keeps the place, and Resume starts there
    When I play {'Test Movie (2020)'} from {'Movies'}
    And I pause after {2} seconds and leave the player
    Then the server keeps the place where I paused
    And Resume starts the movie there

  Scenario: A movie played to its end is watched
    When I play {'Test Movie (2020)'} from {'Movies'}
    And I skip to the end
    Then I am back on the item's page
    And the server has {'Test Movie (2020)'} as watched

  Scenario: A movie played to its end shows as watched in its library
    When I play {'Test Movie (2020)'} from {'Movies'}
    And I skip to the end
    Then I am back on the item's page
    When I go back
    Then {'Test Movie (2020)'} shows as watched
