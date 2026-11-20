Feature: The player on touch

  As phone players are: a tap shows or hides the controls and does not
  pause, a double tap on the left half goes back 10 seconds and on the
  right half on 10 seconds, and the volume is the phone's keys'. Android's
  Back closes the settings panel a level at a time before it leaves the
  player.

  Background:
    Given the app is signed in
    And the app runs on a {'phone'}

  Scenario: A tap hides the controls and another shows them, and neither pauses
    When I play {'movie-1'}
    Then the controls are shown
    When I tap the video
    Then the controls are hidden
    And it is playing
    When I tap the video
    Then the controls are shown
    And it is playing

  Scenario: A double tap on the right goes on 10 seconds, on the left back
    When I play {'movie-1'}
    And {30} seconds have played
    And I double-tap the {'right'} of the video
    Then it is at {40} seconds
    When I double-tap the {'left'} of the video
    Then it is at {30} seconds
    And it is playing

  Scenario: No volume button: the phone has keys for it
    When I play {'movie-1'}
    Then there is no {'mute'} button

  Scenario: The seek bar's preview goes when the finger lifts
    When I play {'movie-1'}
    And I slide a finger along the seek bar
    Then the seek bar shows where it would go
    When I lift the finger
    Then the seek bar shows no preview

  Scenario: Back goes up the settings panel, closes it, then leaves the player
    When I play {'movie-1'}
    And {42} seconds have played
    And I open the subtitles in the settings panel
    And I use the phone's Back
    Then the settings panel shows its list
    When I use the phone's Back
    Then the settings panel is closed
    And the player is still open
    When I use the phone's Back
    Then the player is closed
    And the server is told {'movie-1'} stopped at {42} seconds
