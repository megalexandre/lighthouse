Feature: Reading on a phone

  Android's Back closes the contents first, then leaves the book. The book
  opens full screen: no reader's bars, no phone's bars. A tap in the middle
  shows or hides them together; the page keeps its place, so an EPUB is not
  laid out again. The
  page is the whole screen, its text clear of the notch and the bars. On
  a phone two pages would be too small to read: one at a time, even when
  two are asked for; a tablet still shows them.

  Background:
    Given the app is signed in
    And the app runs on a {'phone'}

  Scenario: Back closes the contents, then leaves the book
    When I read {'book-epub'}
    And I tap the middle
    And I open the contents
    And I use the phone's Back
    Then the contents are closed
    And the book is still open
    When I use the phone's Back
    Then I am back on the book's page

  Scenario: The page is the whole screen
    When I read {'book-epub'}
    Then the page fills the screen
    And the text of {'book-epub'} is clear of the phone's bars

  Scenario: A comic's page is the whole screen
    When I read {'book-comic'}
    Then the page fills the screen
    And the picture is as wide as the screen

  Scenario: The page is the whole screen on its side
    Given the app runs on a {'phone on its side'}
    When I read {'book-epub'}
    Then the page fills the screen
    And the text of {'book-epub'} is clear of the phone's bars
    And the lines of {'book-epub'} are at most {640} wide

  Scenario: A book opens full screen
    When I read {'book-comic'}
    Then the bars are hidden
    And the phone's bars are hidden

  Scenario: A tap in the middle shows the bars, another hides them
    When I read {'book-epub'}
    And I note where the page is
    And I tap the middle
    Then the bars are shown
    And the phone's bars are shown
    And the page is where it was
    When I tap the middle
    Then the bars are hidden
    And the phone's bars are hidden
    And the page is where it was

  Scenario: A book that cannot be opened leaves the phone's bars
    Given the book cannot be downloaded
    When I read {'book-comic'}
    Then the phone's bars are shown

  Scenario: Leaving the book gives the phone's bars back
    When I read {'book-epub'}
    Then the phone's bars are hidden
    When I use the phone's Back
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
    And I tap the middle
    And I pick the {'double'} page layout
    Then the reader shows {'Page 2 of 5'}
    And there is no page on the left

  Scenario: A tablet shows two pages when asked
    Given the app runs on a {'tablet on its side'}
    When I read {'book-comic'}
    And I press {'Right'}
    And I tap the middle
    And I pick the {'double'} page layout
    Then the reader shows {'Pages 2–3 of 5'}
    And there is a page on the left
