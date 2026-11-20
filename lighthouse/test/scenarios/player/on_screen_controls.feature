Feature: On-screen controls

  The seek bar names the chapter under the mouse, shows the picture of
  that moment, and seeks where it is clicked or let go; buttons skip 10 seconds; the settings panel sets the speed, and
  Esc closes it a level at a time before it leaves the player. Paused, a
  big play button shows. Subtitles rise above the controls.

  Background:
    Given the app is signed in

  Scenario: The seek bar names the chapter under the mouse, and a click seeks there
    Given {'movie-1'} has a chapter {'Storm'} from minute {5}
    When I play {'movie-1'}
    And I hover three quarters along the seek bar
    Then I see {'7:30'}
    And I see {'Storm'}
    When I click there
    Then it is at {450} seconds

  Scenario: Dragging the seek bar seeks once, where it is let go
    When I play {'movie-1'}
    And I drag the seek bar from a quarter to halfway
    Then it seeks once, to {300} seconds

  Scenario: The seek bar shows the picture of the moment under the mouse
    Given {'movie-1'} has trickplay pictures
    When I play {'movie-1'}
    And I hover three quarters along the seek bar
    Then I see the picture of that moment

  Scenario: Dragging the volume all the way down
    When I play {'movie-1'}
    And I drag the volume all the way down
    Then the volume is {0}

  Scenario Outline: The player shows the resolution, <badge>
    Given the video is {<height>} pixels high
    When I play {'movie-1'}
    Then the player shows the badge {<badge>}

    Examples:
      | height | badge   |
      | 2160   | '4K'    |
      | 1080   | '1080P' |
      | 720    | '720P'  |

  Scenario: The buttons skip 10 seconds back and forth
    When I play {'movie-1'}
    And {30} seconds have played
    And I tap the {'+10 s'} button
    Then it is at {40} seconds
    When I tap the {'-10 s'} button
    Then it is at {30} seconds

  Scenario: The speed, from the settings panel
    When I play {'movie-1'}
    And I tap the {'settings'} button
    Then I see {'Normal'}
    When I pick the speed {1.5}
    Then it plays at {1.5} times
    And the settings panel is closed

  Scenario: The subtitles in the settings panel, and back to its list
    When I play {'movie-1'}
    And I open the subtitles in the settings panel
    Then I see {'Off'}
    When I go back in the settings panel
    Then the settings panel shows its list

  Scenario: Esc closes the settings panel a level at a time, then leaves
    When I play {'movie-1'}
    And I tap the {'settings'} button
    And I open the speed list
    And I press {'Esc'}
    Then the settings panel shows its list
    When I press {'Esc'}
    Then the settings panel is closed
    And {'movie-1'} is playing
    When I press {'Esc'}
    Then the player is closed

  Scenario: Paused, a big play button plays
    When I play {'movie-1'}
    Then I do not see the big play button
    When I press {'Space'}
    And I tap the {'big play'} button
    Then it is playing
    And I do not see the big play button

  Scenario: Subtitles rise while the controls are up
    When I play {'movie-1'}
    Then the subtitles are lifted above the controls
    When I wait {'4 seconds'}
    Then the subtitles are at the bottom

  Scenario: A double click goes full screen
    When I play {'movie-1'}
    And I double-click the video
    Then the player is full screen
