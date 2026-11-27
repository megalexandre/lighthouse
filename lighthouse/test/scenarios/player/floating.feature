Feature: The floating window

  A video can shrink to a small window over the others, only the picture
  in it ("picture in picture"), and grow back. On the desktop it is the
  app's window, frameless and kept on top, with a few buttons of its own
  on hover: a click pauses, dragging moves it, a double click, I or Esc
  give the window back. On Android it is the system's PiP: it floats by
  itself when the user goes Home while the video plays, its buttons are
  the system's, and closing it leaves the player. It floats on to the
  next episode, as full screen does; music has none.

  Background:
    Given the app is signed in

  Scenario: The button floats the video and gives the window back
    When I play {'movie-1'}
    And I tap the {'floating window'} button
    Then the player floats
    When I hover over the floating window
    And I tap the {'back to the window'} button
    Then the player is back in its window

  Scenario: The window takes the picture's shape
    Given the video is {1920} by {800} pixels
    When I play {'movie-1'}
    And I press {'I'}
    Then the floating window is {2.4} times as wide as high

  Scenario: Esc gives the window back and does not leave the player
    When I play {'movie-1'}
    And I press {'I'}
    And I press {'Esc'}
    Then the player is back in its window
    And the player is still open

  Scenario: Full screen ends to float and comes back after
    When I play {'movie-1'}
    And I press {'F'}
    And I press {'I'}
    Then the player floats
    And the window is not full screen
    When I press {'I'}
    Then the player is full screen

  Scenario: A click on the floating window pauses, dragging moves it
    When I play {'movie-1'}
    And I press {'I'}
    And I click the floating window
    Then it is paused
    When I drag the floating window
    Then the floating window has moved
    And it is paused

  Scenario: Closing the floating window leaves the player
    When I play {'movie-1'}
    And {30} seconds have played
    And I press {'I'}
    And I hover over the floating window
    And I tap the {'close floating window'} button
    Then the player is closed
    And the window does not float
    And the server is told {'movie-1'} stopped at {30} seconds

  Scenario: The next episode floats on
    When I play {'episode-1'}
    And I press {'I'}
    And it plays to its end
    Then {'episode-2'} is playing
    And the player floats

  Scenario: Music does not float
    When I play {'album-1'}
    Then there is no {'floating window'} button

  Scenario: On a phone, going Home floats a video that plays
    Given the app runs on a {'phone'}
    When I play {'movie-1'}
    And I go to the phone's Home
    Then the player floats
    And the player is full screen
    And the floating window's middle button is {'Pause'}
    When I use the floating window's {'play/pause'}
    Then it is paused
    And the floating window's middle button is {'Play'}
    When I use the floating window's {'+10 s'}
    Then it is at {10} seconds

  Scenario: On a phone, a paused video stays when going Home
    Given the app runs on a {'phone'}
    When I play {'movie-1'}
    And I tap the {'play/pause'} button
    And I go to the phone's Home
    Then the window does not float

  Scenario: On a phone, growing the floating window back brings the controls
    Given the app runs on a {'phone'}
    When I play {'movie-1'}
    And I tap the {'floating window'} button
    Then the player floats
    When the floating window grows back
    Then the player is back in its window
    And the player is full screen

  Scenario: On a phone, closing the floating window leaves the player
    Given the app runs on a {'phone'}
    When I play {'movie-1'}
    And I go to the phone's Home
    And the floating window is closed
    Then the player is closed

  Scenario: A phone without picture in picture has no button
    Given the app runs on a {'phone'}
    And the phone cannot float
    When I play {'movie-1'}
    Then there is no {'floating window'} button
