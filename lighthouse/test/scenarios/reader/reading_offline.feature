Feature: Reading while the server is away

  The server keeps the place in a book. While it cannot be reached, the
  app keeps the place itself, opens the book there, and sends it once the
  server is back.

  Background:
    Given the app is signed in

  Scenario: A page turned while the server is away is kept, and sent when it is back
    When I read {'book-comic'}
    And the server goes away
    And I turn the page with the right arrow key
    And I turn the page with the right arrow key
    And I close the book
    And I read it again
    Then the reader shows {'Page 3 of 5'}
    When the server is back
    Then the server keeps page {3} of {'book-comic'}

  Scenario: A book finished while the server is away is marked read when it is back
    When I read {'book-comic'}
    And the server goes away
    And I go to the last page
    And I close the book
    And the server is back
    Then the server has {'book-comic'} as read
