Feature: The player's side panel

  As Stremio's: on an episode, the series' episodes by season, the one
  playing marked, and a tap plays another (where it was left off is
  saved first, as with Next); on a movie with chapters, its chapters, the
  one playing marked, and a tap goes there. It opens from its button, the
  tab on the right edge (while the controls show) or C, over the picture, and closes with its X, a click beside it, Esc or
  the phone's Back, before they leave the player.

  Background:
    Given the app is signed in

  Scenario: An episode's panel lists the series and plays another
    Given {'episode-1'} has been watched
    When I play {'episode-2'}
    And I tap the {'episodes'} button
    Then the panel lists {'1. Episode 1, 2. Episode 2, 3. Episode 3'}
    And the panel marks {'2. Episode 2'} as playing
    And the panel marks {'episode-1'} as watched
    When I pick {'3. Episode 3'} in the panel
    Then the stream of {'episode-3'} is open
    And the server is told {'episode-2'} stopped at {0} seconds

  Scenario: The seasons are tabs, the playing one's first
    Given the series has a second season with {'Episode 4'}
    When I play {'episode-1'}
    And I tap the {'episodes'} button
    Then the panel lists {'1. Episode 1, 2. Episode 2, 3. Episode 3'}
    When I pick {'Season 2'} in the panel
    Then the panel lists {'1. Episode 4'}

  Scenario: A movie's panel lists its chapters and goes to one
    Given {'movie-1'} has a chapter {'Storm'} from minute {5}
    When I play {'movie-1'}
    And I tap the {'chapters'} button
    Then the panel lists {'Opening, Storm'}
    And the panel marks {'Opening'} as playing
    When I pick {'Storm'} in the panel
    Then it is at {300} seconds
    And the panel marks {'Storm'} as playing

  Scenario: A movie without chapters has no panel
    When I play {'movie-1'}
    Then there is no {'chapters'} button
    And there is no {'panel tab'} button

  Scenario: The tab on the right edge opens it
    Given the app runs on a {'phone'}
    When I play {'episode-1'}
    And I tap the {'panel tab'} button
    Then the side panel is open
    When I tap the {'close panel'} button
    Then the side panel is closed

  Scenario: C opens it, Esc closes it and not the player
    When I play {'episode-1'}
    And I press {'C'}
    Then the side panel is open
    When I press {'Esc'}
    Then the side panel is closed
    And the player is still open
    When I press {'Space'}
    Then it is paused

  Scenario: On a phone, Back closes the panel, then the player
    Given the app runs on a {'phone'}
    When I play {'episode-1'}
    And I tap the {'episodes'} button
    And I use the phone's Back
    Then the side panel is closed
    And the player is still open
    When I use the phone's Back
    Then the player is closed
