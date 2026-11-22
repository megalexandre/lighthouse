Feature: Page layout

  On a wide window a book opens as an open book: two pages side by side,
  the cover alone on the right, as in print. The display options keep one
  page however wide the window is, or two however narrow. Pages turn a
  spread at a time: the right page turns over the spine onto the left, and
  a swipe on the left page brings the previous spread back over. The last
  spread marks the book read.

  Background:
    Given the app is signed in

  Scenario: A wide window shows two pages, the cover alone
    Given the window is {1600} by {1000}
    When I read {'book-comic'}
    Then the reader shows {'Page 1 of 5'}
    And there is no page on the left
    When I press {'Right'}
    Then the reader shows {'Pages 2–3 of 5'}
    And there is a page on the left
    When I press {'Left'}
    Then the reader shows {'Page 1 of 5'}

  Scenario: The right page turns over onto the left, and comes back
    Given the window is {1600} by {1000}
    When I read {'book-comic'}
    And I swipe to the next page
    Then the reader shows {'Pages 2–3 of 5'}
    When I swipe to the next page
    Then the reader shows {'Pages 4–5 of 5'}
    When I swipe back to the previous page
    Then the reader shows {'Pages 2–3 of 5'}
    And there is a page on the left
    When I swipe back to the previous page
    Then the reader shows {'Page 1 of 5'}
    And there is no page on the left

  Scenario: The last spread marks the book read
    Given the window is {1600} by {1000}
    When I read {'book-comic'}
    And I press {'End'}
    Then the reader shows {'Pages 4–5 of 5'}
    When I press {'Left'}
    And I press {'Right'}
    And I stop a moment
    Then the server has {'book-comic'} as read

  Scenario: An EPUB is laid out for half the window
    Given the window is {1600} by {1000}
    When I read {'book-epub'}
    Then each page is at most half the window wide

  Scenario: A narrow window shows one page
    Given the window is {800} by {600}
    When I read {'book-comic'}
    And I press {'Right'}
    Then the reader shows {'Page 2 of 5'}
    And there is no page on the left

  Scenario: Two pages when asked, however narrow the window
    Given the window is {800} by {600}
    When I read {'book-comic'}
    And I press {'Right'}
    And I pick the {'double'} page layout
    Then the reader shows {'Pages 2–3 of 5'}
    And there is a page on the left

  Scenario: One page when asked, however wide the window, and kept
    Given the window is {1600} by {1000}
    When I read {'book-comic'}
    And I pick the {'single'} page layout
    And I press {'Right'}
    Then the reader shows {'Page 2 of 5'}
    When I close the book
    And I read it again
    And I press {'Right'}
    Then there is no page on the left
