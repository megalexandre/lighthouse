Feature: Touch

  On touch there is no mouse to rest on a card: a long press opens its
  actions instead of the hover panel (play, mark watched, details). The
  carousel is swiped; its dots only show where it is, too small for a
  finger.

  Background:
    Given the app is signed in

  Scenario: A long press on a card opens its actions, which play
    Given the app runs on a {'phone'}
    When I open the {'Movies'} library
    And I long-press {'Test Movie'}
    Then the card's actions are open
    When I tap {'play'} in the card's actions
    Then the card's actions are closed
    And the player is open

  Scenario: The card's actions mark it watched
    Given the app runs on a {'phone'}
    When I open the {'Movies'} library
    And I long-press {'Test Movie'}
    And I tap {'watched'} in the card's actions
    Then the server is told {'Test Movie'} was watched
    And the card's actions are closed

  Scenario: The card's actions open the details
    Given the app runs on a {'phone'}
    When I open the {'Movies'} library
    And I long-press {'Test Movie'}
    And I tap {'details'} in the card's actions
    Then I see the page of {'Test Movie'}

  Scenario: On the desktop a long press opens nothing
    Given the theme is {'Prime'}
    When I open the {'Movies'} library
    And I long-press {'Test Movie'}
    Then the card's actions are closed

  Scenario: A swipe to the left shows the next slide, to the right the one before
    Given the app runs on a {'phone'}
    When I go home
    Then the carousel shows {'Test Movie'}
    When I swipe the carousel to the {'left'}
    Then the carousel shows {'HEVC Movie'}
    When I swipe the carousel to the {'right'}
    Then the carousel shows {'Test Movie'}

  Scenario: A slow drag does not change the slide
    Given the app runs on a {'phone'}
    When I go home
    And I drag the carousel slowly a little to the left
    Then the carousel shows {'Test Movie'}

  Scenario: The carousel's dots take no taps
    Given the app runs on a {'phone'}
    When I go home
    And I tap the dot {2} of the carousel
    Then the carousel shows {'Test Movie'}
