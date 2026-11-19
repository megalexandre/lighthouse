Feature: Play on
  After an episode the next one starts by itself, and an album plays
  track after track.

  Background:
    Given I am signed in as a new user

  Scenario: An episode played to its end starts the next one
  
    When I play episode {'Test Show S01E01'} of {'Test Show'}
    And I skip to the end
    Then {'Test Show S01E02'} is playing
    And the server has {'Test Show S01E01'} as watched

  Scenario: Next plays the album's second track
    When I play {'Test Album'} from {'Music'}
    Then {'Track 1'} is playing
    When I tap Next
    Then {'Track 2'} is playing
    And there is no next track
