Feature: Cards

  A card shows on its picture whether the item was watched, or how far it
  got. Under the mouse a Lanterna card lifts and shows a play button, which
  plays at once; a Prime card opens, after a moment, a panel with the
  whole item. Reduced motion keeps cards still.

  Background:
    Given the app is signed in

  Scenario: A watched item shows a check; a started one, how far it got
    Given {'Test Movie'} was watched
    And {'HEVC Movie'} is {30} percent watched
    When I open the {'Movies'} library
    Then the card of {'Test Movie'} shows a check
    And the card of {'HEVC Movie'} shows how far it got

  Scenario: Under the mouse a card lifts and shows Play, which plays at once
    When I open the {'Movies'} library
    Then the card of {'Test Movie'} has no play button
    When I rest the mouse on {'Test Movie'}
    Then the card of {'Test Movie'} is lifted
    And after a moment no panel opens
    When I tap the play button of {'Test Movie'}
    Then the player is open

  Scenario: With reduced motion the card does not grow
    Given animations are reduced
    When I open the {'Movies'} library
    And I rest the mouse on {'Test Movie'}
    Then the card of {'Test Movie'} has a play button
    And the card of {'Test Movie'} is not lifted

  Scenario: A series has no play button; it opens
    When I open the {'Shows'} library
    And I rest the mouse on {'Test Show'}
    Then the card of {'Test Show'} has no play button
    When I open {'Test Show'}
    Then I see the page of {'Test Show'}

  Scenario: In Prime, a card under the mouse opens a panel after a moment
    Given the theme is {'Prime'}
    When I open the {'Movies'} library
    And I rest the mouse on {'Test Movie'}
    Then after half a moment no panel is open
    And after a moment the panel opens
    And the panel shows {'A movie made for tests.'}
    And the card of {'Test Movie'} is not lifted
    When I move the mouse away
    Then the panel is closed

  Scenario: In Prime, the panel marks watched, opens the page, and plays
    Given the theme is {'Prime'}
    When I open the {'Movies'} library
    And I rest the mouse on {'Test Movie'}
    And after a moment the panel opens
    And I tap {'watched'} in the panel
    Then the server is told {'Test Movie'} was watched
    When I tap {'details'} in the panel
    Then I see the page of {'Test Movie'}
    And the panel is closed
    When I go back
    And I move the mouse away
    And I rest the mouse on {'Test Movie'}
    And after a moment the panel opens
    And I tap {'play'} in the panel
    Then the player is open

  Scenario Outline: In Prime, the panel's <part> opens the item's page
    Given the theme is {'Prime'}
    When I open the {'Movies'} library
    And I rest the mouse on {'Test Movie'}
    And after a moment the panel opens
    And I tap {<part>} in the panel
    Then I see the page of {'Test Movie'}

    Examples:
      | part      |
      | 'picture' |
      | 'title'   |
      | 'details' |

  Scenario: In Prime, a series' panel opens its episodes
    Given the theme is {'Prime'}
    And {'Test Show'} has {2} seasons
    When I open the {'Shows'} library
    And I rest the mouse on {'Test Show'}
    And after a moment the panel opens
    Then the panel shows {'2 seasons'}
    And the panel shows {'Episodes'}
    When I tap {'play'} in the panel
    Then I see the page of {'Test Show'}

  Scenario: In Prime, an episode's panel names its series
    Given the theme is {'Prime'}
    And {'Episode 2'} is next up
    When I go home
    And I scroll to the {'Next up'} row
    And I rest the mouse on {'Episode 2'}
    And after a moment the panel opens
    Then the panel shows {'Test Show · S1:E2'}

  Scenario: In Prime, a watched movie can be marked unwatched from its panel
    Given the theme is {'Prime'}
    And {'Test Movie'} was watched
    When I open the {'Movies'} library
    And I rest the mouse on {'Test Movie'}
    And after a moment the panel opens
    Then I see a button {'Mark as unwatched'}
    When I tap {'watched'} in the panel
    Then the server is told {'Test Movie'} was not watched

  Scenario: In Prime, marking watched when the server cannot save it says so
    Given the theme is {'Prime'}
    And the server cannot save what was watched or read
    When I open the {'Movies'} library
    And I rest the mouse on {'Test Movie'}
    And after a moment the panel opens
    And I tap {'watched'} in the panel
    Then I see a message {'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.'}
