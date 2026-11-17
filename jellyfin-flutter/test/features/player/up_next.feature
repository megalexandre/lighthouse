Feature: Up next

  When an episode nears its end, the player offers the next one, and plays
  it on at the end, unless the user turned next episode autoplay off.

  Background:
    Given the app is signed in

  Scenario: The next episode is offered in the last seconds
    When I play {'episode-1'}
    And the episode reaches its last {6} seconds
    Then I see the up next card for {'S1:E2 · Episode 2'}

  Scenario: Watch now plays the next episode at once
    When I play {'episode-1'}
    And the episode reaches its last {6} seconds
    And I tap watch now
    Then {'episode-2'} is playing

  Scenario: Hidden, the next episode still plays at the end
    When I play {'episode-1'}
    And the episode reaches its last {6} seconds
    And I hide the up next card
    And the episode plays to its end
    Then {'episode-2'} is playing

  Scenario: With autoplay off, nothing is offered
    Given next episode autoplay is off
    When I play {'episode-1'}
    And the episode reaches its last {6} seconds
    Then I do not see the up next card
