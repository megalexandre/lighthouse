Feature: Full screen with a mouse

  The same as on a phone: in full screen the page is the whole screen, and
  the bars come over it. F11 or F, or the button in the top bar, go in and
  out; Esc leaves full screen before it leaves the book. Going in hides the
  bars; a click in the middle brings them back over the page. Leaving the
  book leaves full screen too.

  Background:
    Given the app is signed in
    And the window is {1000} by {1200}

  Scenario: F11 makes the page the whole screen
    When I read {'book-epub'}
    And I press {'F11'}
    Then the window is full screen
    And the bars are hidden
    And the page fills the screen
    And the lines of {'book-epub'} are at most {640} wide
    When I press {'F11'}
    Then the window is not full screen
    And the bars are shown

  Scenario: Esc leaves full screen, then the book
    When I read {'book-comic'}
    And I press {'F'}
    Then the window is full screen
    When I press {'Esc'}
    Then the window is not full screen
    And the book is still open
    When I press {'Esc'}
    Then I am back on the book's page

  Scenario: The button goes full screen, a click brings the bars back
    When I read {'book-comic'}
    And I tap the full screen button
    Then the window is full screen
    And the bars are hidden
    And the page fills the screen
    When I tap the middle
    Then the bars are shown
    And the window is full screen
    When I tap the full screen button
    Then the window is not full screen

  Scenario: Leaving the book leaves full screen
    When I read {'book-epub'}
    And I press {'F'}
    And I tap the middle
    And I close the book
    Then the window is not full screen
