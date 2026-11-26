Feature: Swipes on the video

  As phone players have them: up and down on the left half for the
  screen's brightness, on the right half for the phone's volume (the one
  its keys change); sideways to seek, once the finger lifts. A swipe from
  an edge is the system's (Back, the notifications). Each kind can be
  turned off in Settings. With a mouse, the wheel over the video changes
  the volume, as the up and down keys do.

  Background:
    Given the app is signed in

  Scenario: Up on the right half raises the phone's volume, down lowers it
    Given the app runs on a {'phone'}
    And the phone's volume is set to {20} percent
    When I play {'movie-1'}
    And I swipe up {30} percent of the video on its {'right'} half
    Then the phone's volume is {70} percent
    When I swipe down {60} percent of the video on its {'right'} half
    Then the phone's volume is {0} percent

  Scenario: Up on the left half brightens the screen until the player closes
    Given the app runs on a {'phone'}
    And the screen's brightness is set to {50} percent
    When I play {'movie-1'}
    And I swipe up {15} percent of the video on its {'left'} half
    Then the screen's brightness is {75} percent
    When I use the phone's Back
    Then the player is closed
    And the screen is back to its own brightness

  Scenario: Sideways seeks when the finger lifts, showing where to
    Given the app runs on a {'phone'}
    When I play {'movie-1'}
    And {30} seconds have played
    And I put a finger down and slide it {50} percent of the video to the {'right'}
    Then the swipe shows {'+1:00'}
    And it is at {30} seconds
    When I lift the finger
    Then it is at {90} seconds
    When I swipe {50} percent of the video to the {'left'}
    Then it is at {30} seconds

  Scenario: A swipe from an edge is left to the system
    Given the app runs on a {'phone'}
    And the phone's volume is set to {20} percent
    When I play {'movie-1'}
    And I swipe up from the bottom edge on the {'right'} half
    Then the phone's volume is {20} percent

  Scenario: Turned off in Settings, the swipes do nothing
    Given the app runs on a {'phone'}
    And the phone's volume is set to {20} percent
    When I turn off {'Swipe for brightness and volume'} in Settings
    And I turn off {'Swipe to seek'} in Settings
    And I play {'movie-1'}
    And {30} seconds have played
    And I swipe up {30} percent of the video on its {'right'} half
    And I swipe {50} percent of the video to the {'right'}
    Then the phone's volume is {20} percent
    And it is at {30} seconds

  Scenario: With a mouse, the wheel over the video changes the volume
    When I play {'movie-1'}
    And I scroll down over the video
    Then the volume is {95}
    When I scroll up over the video
    Then the volume is {100}
