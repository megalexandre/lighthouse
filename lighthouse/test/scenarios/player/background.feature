Feature: Playing in the background

  Music goes on with the phone's screen off, song after song: Flutter draws
  no frames there, so the next song starts without one. The phone's media
  notification (the lock screen, a headset) drives it. Music and video take
  turns at the sound with the phone's calls and other apps.

  Background:
    Given the app is signed in
    And the app runs on a {'phone'}

  Scenario: An album plays through with the screen off
    When I play {'album-1'}
    And the screen goes off
    And it plays to its end without a frame
    Then the stream of {'track-2'} is open
    And only its sound was opened
    And the notification shows {'Track 2'}
    And the server is told {'track-1'} stopped at {600} seconds
    When the screen comes back on
    Then the player shows {'Track 2'}

  Scenario: After the last song the notification goes
    When I play {'album-1'}
    And the screen goes off
    And it plays to its end without a frame
    And it plays to its end without a frame
    Then there is no notification
    And other apps can play
    When the screen comes back on
    Then the player is closed

  Scenario: The notification changes songs
    When I play {'album-1'}
    Then the notification shows {'Track 1'}
    When I use the notification's {'next'}
    Then the player shows {'Track 2'}
    And the notification shows {'Track 2'}
    And the notification has no next
    When I use the notification's {'previous'}
    Then the player shows {'Track 1'}

  Scenario: Previous restarts a song that is under way
    When I play {'album-1'}
    And {30} seconds have played
    Then the notification is at {30} seconds
    When I use the notification's {'previous'}
    Then the notification shows {'Track 1'}
    And the notification is at {0} seconds

  Scenario: The notification pauses and plays
    When I play {'album-1'}
    And I use the notification's {'pause'}
    Then it is paused
    And the notification shows it {'paused'}
    When I use the notification's {'play'}
    Then it is playing
    And the notification shows it {'playing'}

  Scenario: Dismissing the notification pauses; it comes back with the music
    When I play {'album-1'}
    And I dismiss the notification
    Then it is paused
    And there is no notification
    And other apps can play
    When I tap the {'play/pause'} button
    Then it is playing
    And the notification shows {'Track 1'}

  Scenario: Leaving the player takes the notification with it
    When I play {'album-1'}
    And I use the phone's Back
    Then the player is closed
    And there is no notification
    And other apps can play

  Scenario: A song that cannot be reached can be tried again
    When I play {'album-1'}
    And the next song cannot be reached
    And it plays to its end
    Then there is no notification
    When the server can be reached again
    And I tap Retry
    Then the player shows {'Track 2'}
    And the notification shows {'Track 2'}

  Scenario: Video has no notification
    When I play {'movie-1'}
    Then there is no notification

  Scenario: A call pauses the music, which goes on after it
    When I play {'album-1'}
    And a call comes in
    Then it is paused
    When the call ends
    Then it is playing

  Scenario: Music paused by hand during a call stays paused
    When I play {'album-1'}
    And a call comes in
    And I use the notification's {'pause'}
    And the call ends
    Then it is paused

  Scenario: Music that was paused stays so after a call
    When I play {'album-1'}
    And I use the notification's {'pause'}
    And a call comes in
    And the call ends
    Then it is paused

  Scenario: Another app's music stops this one for good
    When I play {'album-1'}
    And another app starts playing
    Then it is paused
    When the call ends
    Then it is paused

  Scenario: Unplugging the headphones pauses
    When I play {'movie-1'}
    And the headphones are unplugged
    Then it is paused

  Scenario: During a call nothing starts playing
    Given a call is on
    When I play {'movie-1'}
    Then it is paused

  Scenario: A video paused by a call does not play in the background
    When I play {'movie-1'}
    And a call comes in
    And the screen goes off
    And the call ends
    Then it is paused

  Scenario: The next episode keeps the sound
    When I play {'episode-1'}
    And it plays to its end
    Then {'episode-2'} is playing
    And it is playing
    And the sound is the app's

  Scenario: A video plays sideways and full screen, until it is left
    When I play {'movie-1'}
    Then the phone is held sideways
    And the player is full screen
    When I use the phone's Back
    Then the player is closed
    And the phone turns freely
    And the window is not full screen

  Scenario: The next episode stays sideways
    When I play {'episode-1'}
    And it plays to its end
    Then {'episode-2'} is playing
    And the phone is held sideways
    And the player is full screen

  Scenario: Music leaves the phone as it is held
    When I play {'album-1'}
    Then the phone turns freely
    And the window is not full screen
