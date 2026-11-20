Feature: Player controls

  The audio and subtitle menus, and the keys of the desktop client: A for
  audio, L and S for subtitles (Ctrl+A and Ctrl+L the other way), the arrows and M for the volume, F and F11
  for full screen. The server is told what plays.

  Background:
    Given the app is signed in

  Scenario: It starts with the server's default audio and no subtitle
    When I play {'movie-1'}
    Then the {'English'} audio track plays
    And no subtitle is shown
    And the server is told the {'English'} audio track
    And the server is told no subtitle

  Scenario: A subtitle the server suggests shows from the start
    Given the server suggests the {'English'} subtitle
    When I play {'movie-1'}
    Then the {'English'} subtitle is shown

  Scenario: An audio track picked from the menu
    When I play {'movie-1'}
    And I pick the {'Portuguese'} audio track from the menu
    Then the {'Portuguese'} audio track plays
    And the server is told the {'Portuguese'} audio track
    And the menu has the {'Portuguese'} audio track checked

  Scenario: A subtitle picked from the menu, then turned off
    When I play {'movie-1'}
    And I pick the {'Portuguese'} subtitle from the menu
    Then the {'Portuguese'} subtitle is shown
    And the server is told the {'Portuguese'} subtitle
    When I turn the subtitles off from the menu
    Then no subtitle is shown
    And the server is told no subtitle

  Scenario: A cycles the audio
    When I play {'movie-1'}
    And I press {'A'}
    Then the {'Portuguese'} audio track plays
    When I press {'A'}
    Then the {'English'} audio track plays

  Scenario: Ctrl+A cycles the audio the other way
    When I play {'movie-1'}
    And I press {'Ctrl+A'}
    Then the {'Portuguese'} audio track plays
    When I press {'Ctrl+A'}
    Then the {'English'} audio track plays

  Scenario: L cycles the subtitles through off; S shows and hides them
    When I play {'movie-1'}
    And I press {'L'}
    Then the {'Portuguese'} subtitle is shown
    When I press {'L'}
    Then the {'English'} subtitle is shown
    When I press {'L'}
    Then no subtitle is shown
    When I press {'S'}
    Then the {'English'} subtitle is shown
    When I press {'S'}
    Then no subtitle is shown

  Scenario: Ctrl+L cycles the subtitles the other way
    When I play {'movie-1'}
    And I press {'Ctrl+L'}
    Then the {'English'} subtitle is shown
    When I press {'Ctrl+L'}
    Then the {'Portuguese'} subtitle is shown
    When I press {'Ctrl+L'}
    Then no subtitle is shown

  Scenario: The volume, from the arrows and mute, and what the server is told
    When I play {'movie-1'}
    And I press {'Down'}
    And I press {'Down'}
    Then the volume is {90}
    When I press {'Up'}
    Then the volume is {95}
    When I tap the {'mute'} button
    Then the volume is {95}, muted
    And I see a button {'Unmute (M)'}
    When I press {'Up'}
    Then the volume is {100}
    When I press {'M'}
    And I tap the {'play/pause'} button
    Then the server is told the volume is {100}, muted

  Scenario: Full screen from F11, the button and F; leaving gives the window back
    When I play {'movie-1'}
    And I press {'F11'}
    Then the player is full screen
    And I see a button {'Exit full screen (F)'}
    When I tap the {'full screen'} button
    Then the window is not full screen
    When I press {'F'}
    Then the player is full screen
    When I press {'Esc'}
    Then the window is not full screen

  Scenario: In a transcode, another audio track is a new stream from the same place
    Given the movie plays as a transcode
    When I play {'movie-1'}
    And {30} seconds have played
    And I pick the {'Portuguese'} audio track from the menu
    Then the server is asked for a new stream from {30} seconds with the {'Portuguese'} audio track
    And it started at {30} seconds
    And the server is told {'movie-1'} stopped at {30} seconds

  Scenario: In a transcode, a subtitle inside the file is a new stream from the same place
    Given the movie plays as a transcode
    When I play {'movie-1'}
    And {30} seconds have played
    And I pick the {'English'} subtitle from the menu
    Then the server is asked for a new stream from {30} seconds with the {'English'} subtitle
    And it started at {30} seconds

  Scenario: A stream mpv cannot open says so
    Given mpv cannot open the stream
    When I play {'movie-1'}
    Then I see {'Playback failed: the stream could not be opened.'}

  Scenario: In a transcode, a stream the server cannot give leaves the old one playing
    Given the movie plays as a transcode
    When I play {'movie-1'}
    And {30} seconds have played
    And the server stops answering
    And I pick the {'Portuguese'} audio track from the menu
    Then I see the message {'The server answered with error 503.'}
    And only one stream was opened
    When {10} seconds have played
    And I press {'Esc'}
    Then the server is told {'movie-1'} stopped at {40} seconds
