Feature: Playing on

  An episode played to its end goes on to the next; Next and Previous move
  through the season. An album plays through, its cover on screen. Full
  screen and the volume carry on from one episode to the next.

  Background:
    Given the app is signed in

  Scenario: At the end of an episode the next one starts
    When I play {'episode-1'}
    And it plays to its end
    Then {'episode-2'} is playing
    And the player shows {'Episode 2'}
    And it started at {0} seconds
    And the player of the one before is let go
    And the server is told {'episode-1'} stopped at {600} seconds
    When I press {'Esc'}
    Then I am back on the page of {'Episode 1'}

  Scenario: After the last episode, back to its page
    When I play {'episode-3'}
    Then there is no {'next'} button
    When it plays to its end
    Then I am back on the page of {'Episode 3'}

  Scenario: Next saves the place and plays the next episode
    When I play {'episode-1'}
    And {20} seconds have played
    And I tap the {'next'} button
    Then the player shows {'Episode 2'}
    And the server is told {'episode-1'} stopped at {20} seconds

  Scenario: Previous restarts the episode, then goes back one
    When I play {'episode-2'}
    And {10} seconds have played
    And I tap the {'previous'} button
    Then the player shows {'Episode 2'}
    And it is at {0} seconds
    When I tap the {'previous'} button
    Then the player shows {'Episode 1'}

  Scenario: Before the first episode, Previous only restarts
    When I play {'episode-1'}
    And {1} seconds have played
    And I press {'Home'}
    Then the player shows {'Episode 1'}
    And it is at {0} seconds

  Scenario: The next-track media key plays the next episode
    When I play {'episode-1'}
    And I press {'Next track'}
    Then the player shows {'Episode 2'}

  Scenario: A movie has no Next
    When I play {'movie-1'}
    Then there is no {'next'} button

  Scenario: An album plays through, its cover on screen
    When I play {'album-1'}
    Then I see the cover
    And {'track-1'} is playing
    And the player shows {'Track 1'}
    And I see {'Test Artist · Test Album'}
    When I wait {'5 seconds'}
    Then the controls are shown
    When it plays to its end
    Then the player shows {'Track 2'}
    When it plays to its end
    Then the player is closed

  Scenario: A track picked from the album plays alone
    When I open the page of {'album-1'}
    And I tap {'Track 2'}
    Then the player shows {'Track 2'}
    And there is no {'next'} button

  Scenario: Full screen and the volume carry on to the next episode
    When I play {'episode-1'}
    And I press {'F'}
    And I press {'Down'}
    And I press {'Down'}
    And I press {'M'}
    Then the player is full screen
    And the volume is {90}, muted
    When it plays to its end
    Then the player shows {'Episode 2'}
    And the player is full screen
    And the volume is {90}, muted
    When I press {'Next track'}
    Then the player is full screen
    When I press {'Esc'}
    Then the player is closed
    And the window is not full screen

  Scenario: With autoplay off, the player closes at the end of an episode
    Given next episode autoplay is off
    When I play {'episode-1'}
    And it plays to its end
    Then I am back on the page of {'Episode 1'}
    And the player is let go
