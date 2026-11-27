Feature: Player controls
  The real app plays the Test Movie in mpv: the volume, mute and speed
  chosen in the player are what mpv plays with.

  Scenario: Volume, mute and speed reach mpv
    Given I am signed in as a new user
    When I play {'Test Movie (2020)'} from {'Movies'}
    And I press {'Down'} in the player
    And I press {'Down'} in the player
    And I press {'M'} in the player
    And I pick the speed {1.5}
    Then mpv plays at volume {90}, muted, at {1.5} times the speed

  Scenario: mpv draws the picture at its size on screen
    Given I am signed in as a new user
    When I play {'Test Movie (2020)'} from {'Movies'}
    Then mpv draws at the size the video takes on screen

  Scenario: Locked, a key reaches the padlock and not mpv
    Given I am signed in as a new user
    When I play {'Test Movie (2020)'} from {'Movies'}
    And I lock the player
    And I press {'Space'} in the player
    Then mpv is still playing
    When I hold the padlock
    Then the player's controls are back
