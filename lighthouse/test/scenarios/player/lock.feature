Feature: Locking the player's controls

  As Jellyfin's Android app has it, against touches by mistake (a pocket,
  a palm, a child): the lock button hides the controls, and nothing
  answers (taps, swipes, keys, the phone's Back and volume keys, the
  notification, a headset) until the padlock is held for a moment. A
  touch, a key or the mouse only shows the padlock, on the left edge.
  The next episode stays locked; closing the player unlocks.

  Background:
    Given the app is signed in

  Scenario: Locked, a tap shows only the padlock
    Given the app runs on a {'phone'}
    When I play {'movie-1'}
    And I tap the {'lock'} button
    Then the controls are hidden
    And I see the {'unlock'} button
    When I wait {'4 seconds'}
    Then there is no {'unlock'} button
    When I tap the video
    Then I see the {'unlock'} button
    And the controls are hidden

  Scenario: A short press does not unlock, holding does
    Given the app runs on a {'phone'}
    When I play {'movie-1'}
    And I tap the {'lock'} button
    And I tap the {'unlock'} button
    Then the controls are hidden
    When I hold the {'unlock'} button for {2} seconds
    Then the controls are shown
    And there is no {'unlock'} button

  Scenario: Locked, swipes and double taps do nothing
    Given the app runs on a {'phone'}
    And the phone's volume is set to {50} percent
    When I play {'movie-1'}
    And I tap the {'lock'} button
    And I swipe up {30} percent of the video on its {'right'} half
    Then the phone's volume is {50} percent
    When I double-tap the {'right'} of the video
    Then it is at {0} seconds

  Scenario: Locked, the phone's Back and volume keys do nothing
    Given the app runs on a {'phone'}
    When I play {'movie-1'}
    And I tap the {'lock'} button
    Then the phone's volume keys do nothing
    When I use the phone's Back
    Then the player is still open
    And I see the {'unlock'} button
    When I hold the {'unlock'} button for {2} seconds
    Then the phone's volume keys work

  Scenario: Locked, keys only show the padlock, and Enter held unlocks
    When I play {'movie-1'}
    And I tap the {'lock'} button
    And I wait {'4 seconds'}
    And I press {'Space'}
    Then it is playing
    And I see the {'unlock'} button
    When I press {'Esc'}
    Then the player is still open
    When I hold {'Enter'} for {2} seconds
    Then the controls are shown

  Scenario: The next episode stays locked
    When I play {'episode-1'}
    And I tap the {'lock'} button
    And the episode reaches its last {6} seconds
    Then I do not see the up next card
    When the episode plays to its end
    Then {'episode-2'} is playing
    And the controls are hidden
    And I see the {'unlock'} button

  Scenario: Closing the player unlocks
    When I play {'movie-1'}
    And I tap the {'lock'} button
    And it plays to its end
    Then the player is closed
    When I play {'movie-1'}
    Then the controls are shown
    And there is no {'unlock'} button

  Scenario: Locked music keeps its cover and time, its notification no buttons
    Given the app runs on a {'phone'}
    When I play {'album-1'}
    And I tap the {'lock'} button
    Then I see the cover
    And the notification has no buttons
    When I use the notification's {'pause'}
    Then it is playing
    When I hold the {'unlock'} button for {2} seconds
    Then the notification has its buttons
    When I use the notification's {'pause'}
    Then it is paused
