Feature: Playing while the server goes away

  Playback that breaks off keeps the player open, with the place it got
  to, and offers to resume from there. Where playback stopped while the
  server was away reaches it when it is back.

  Background:
    Given the app is signed in

  Scenario: Playback that breaks off offers to resume where it was
    When I play {'movie-1'}
    And {30} seconds have played
    And the playback breaks off
    Then the player is still open
    And I see {'Resume from 0:30'}
    And the server is told {'movie-1'} stopped at {30} seconds
    When I tap the {'resume after break'} button
    Then it started at {30} seconds
    And I do not see {'Resume from 0:30'}

  Scenario: Where it stopped while the server was away reaches it later
    When I play {'movie-1'}
    And {42} seconds have played
    And the server cannot be told playback stopped
    And I press {'Esc'}
    Then the server has not been told where it stopped
    When the server is back
    Then the server is told {'movie-1'} stopped at {42} seconds
