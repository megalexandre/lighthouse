Feature: Playing

  Play opens the stream from the start; a movie stopped partway offers to
  resume. The player pauses, seeks and hides its controls while playing.
  Leaving it, or the end, tells the server where it stopped.

  Background:
    Given the app is signed in

  Scenario: Play starts the movie from the beginning
    When I play {'movie-1'}
    Then {'movie-1'} is playing
    And it started at {0} seconds
    And the server is told {'movie-1'} started

  Scenario: A movie stopped partway offers to resume
    Given {'movie-1'} was stopped at {64} seconds
    When I open the page of {'movie-1'}
    Then I see {'Resume from 1:04'}
    And I see {'Start over'}
    When I tap the {'resume'} button
    Then it started at {64} seconds

  Scenario: Back saves the place and returns to the page
    When I play {'movie-1'}
    And {42} seconds have played
    And I tap the {'back'} button
    Then I am back on the page of {'Test Movie'}
    And the server is told {'movie-1'} stopped at {42} seconds
    And the player is let go

  Scenario: Esc leaves too
    When I play {'movie-1'}
    And I press {'Esc'}
    Then I am back on the page of {'Test Movie'}
    And the server is told {'movie-1'} stopped at {0} seconds

  Scenario: The button and Space pause and play
    When I play {'movie-1'}
    And I tap the {'play/pause'} button
    Then it is paused
    And the server is told it is paused
    And I see the big play button
    And I see a button {'Play (Space)'}
    When I press {'Space'}
    Then it is playing
    And the server is told it is playing

  Scenario: The arrows seek 10 seconds, never before the start
    When I play {'movie-1'}
    And I press {'Right'}
    Then it is at {10} seconds
    When I press {'Left'}
    And I press {'Left'}
    Then it is at {0} seconds
    And the position reads {'0:00'}

  Scenario: The controls hide while playing, and stay while paused
    When I play {'movie-1'}
    Then the controls are shown
    When I wait {'4 seconds'}
    Then the controls are hidden
    When I press {'Space'}
    Then the controls are shown
    When I wait {'4 seconds'}
    Then the controls are shown

  Scenario: Played to the end, the player closes and the server knows
    When I play {'movie-1'}
    And it plays to its end
    Then the player is closed
    And the server is told {'movie-1'} stopped at {600} seconds

  Scenario: What cannot be played says why
    Given {'movie-1'} cannot be played
    When I play {'movie-1'}
    Then I see {'This item cannot be played (NotAllowed).'}
    And no stream is opened
    When I tap the {'back'} button
    Then I am back on the page of {'Test Movie'}

  Scenario: A stream the server cannot give can be asked for again
    Given the server stops answering
    When I play {'movie-1'}
    Then I see {'The server answered with error 503.'}
    When the server answers again
    And I tap Retry
    Then {'movie-1'} is playing

  Scenario: Marking as watched tells the server
    When I open the page of {'movie-1'}
    And I tap the {'watched'} button
    Then the server is told {'movie-1'} was watched

  Scenario: Series have no Play button
    When I open the page of {'series-1'}
    Then there is no {'play'} button
