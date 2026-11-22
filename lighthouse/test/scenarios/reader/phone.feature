Feature: Reading on a phone

  Android's Back closes the contents first, then leaves the book. A tap in
  the middle hides the reader's bars and the phone's together (full
  screen); the page keeps its place, so an EPUB is not laid out again. On
  a phone two pages would be too small to read: one at a time, even when
  two are asked for; a tablet still shows them.

  Background:
    Given the app is signed in
    And the app runs on a {'phone'}

  Scenario: Back closes the contents, then leaves the book
    When I read {'book-epub'}
    And I open the contents
    And I use the phone's Back
    Then the contents are closed
    And the book is still open
    When I use the phone's Back
    Then I am back on the book's page

  Scenario: Hiding the bars goes full screen
    When I read {'book-epub'}
    And I note where the page is
    And I tap the middle
    Then the bars are hidden
    And the phone's bars are hidden
    And the page is where it was
    When I tap the middle
    Then the bars are shown
    And the phone's bars are shown

  Scenario: Leaving the book gives the phone's bars back
    When I read {'book-epub'}
    And I tap the middle
    And I use the phone's Back
    Then I am back on the book's page
    And the phone's bars are shown

  Scenario: The screen stays on while a book is open
    When I read {'book-epub'}
    Then the screen stays on
    When I use the phone's Back
    Then I am back on the book's page
    And the screen may turn off

  Scenario: One page on its side, even when two are asked for
    Given the app runs on a {'phone on its side'}
    When I read {'book-comic'}
    And I press {'Right'}
    And I pick the {'double'} page layout
    Then the reader shows {'Page 2 of 5'}
    And there is no page on the left

  Scenario: A tablet shows two pages when asked
    Given the app runs on a {'tablet on its side'}
    When I read {'book-comic'}
    And I press {'Right'}
    And I pick the {'double'} page layout
    Then the reader shows {'Pages 2–3 of 5'}
    And there is a page on the left
