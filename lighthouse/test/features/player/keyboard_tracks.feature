Feature: Tracks from the keyboard

  A switches the audio track. A transcoded movie carries only the tracks it
  was made with, so the player asks the server for a new stream, which can
  fail: the player says so, as it does from the menu.

  Background:
    Given the app is signed in

  Scenario: A switches to the next audio track
    When I play {'movie-1'}
    And I switch the audio with the keyboard
    Then the {'Portuguese'} audio track plays

  Scenario: An audio track the server cannot give says so
    Given the movie plays as a transcode
    When I play {'movie-1'}
    And the server stops answering
    And I switch the audio with the keyboard
    Then I see the message {'The server answered with error 503.'}
