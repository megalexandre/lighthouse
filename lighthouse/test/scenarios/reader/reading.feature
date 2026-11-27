Feature: Reading

  A book opens on its first page, or where it was left. Swipes (forward
  and back), the arrow keys and taps on the screen's edges turn pages;
  Home and End jump; a tap in the middle hides the bars. The place is saved once the reader stops a
  moment, and at once on leaving; the last page marks the book read.

  Background:
    Given the app is signed in
    And the reader shows one page at a time

  Scenario: A new book opens on its first page
    When I open the page of {'book-comic'}
    Then I see {'Read'}
    When I read it
    Then the reader shows {'Page 1 of 5'}
    And I see {'Test Comic'}

  Scenario: A started book opens where it was left
    Given {'book-comic'} was left on page {3} at {40} percent
    When I open the page of {'book-comic'}
    Then I see {'Continue reading · 40%'}
    When I read it
    Then the reader shows {'Page 3 of 5'}

  Scenario: A swipe turns the page, and the place is saved
    When I read {'book-comic'}
    And I swipe to the next page
    Then the reader shows {'Page 2 of 5'}
    When I stop a moment
    Then the server is told only page {2} of {'book-comic'}

  Scenario: A swipe back brings the previous page
    When I read {'book-comic'}
    And I swipe to the next page
    And I swipe to the next page
    Then the reader shows {'Page 3 of 5'}
    When I swipe back to the previous page
    Then the reader shows {'Page 2 of 5'}

  Scenario: Pages turned quickly are saved once, where the reader stops
    When I read {'book-comic'}
    And I turn the page with the right arrow key
    And I turn the page with the right arrow key
    Then the server has not been told the place
    When I stop a moment
    Then the reader shows {'Page 3 of 5'}
    And the server is told only page {3} of {'book-comic'}

  Scenario: Keys and the screen's edges turn pages; Home and End jump
    When I read {'book-comic'}
    And I turn the page with the right arrow key
    Then the reader shows {'Page 2 of 5'}
    When I press {'End'}
    Then the reader shows {'Page 5 of 5'}
    When I press {'Home'}
    Then the reader shows {'Page 1 of 5'}
    When I tap the {'right'} edge
    Then the reader shows {'Page 2 of 5'}
    When I tap the {'left'} edge
    Then the reader shows {'Page 1 of 5'}

  Scenario: The mouse wheel turns pages, one per notch
    When I read {'book-comic'}
    And I scroll the mouse wheel {'down'}
    Then the reader shows {'Page 2 of 5'}
    When I scroll the mouse wheel {'down'}
    Then the reader shows {'Page 3 of 5'}
    When I scroll the mouse wheel {'up'}
    Then the reader shows {'Page 2 of 5'}

  Scenario: A burst of scrolls from a touchpad turns a single page
    When I read {'book-comic'}
    And I scroll the touchpad {'down'} in a burst
    Then the reader shows {'Page 2 of 5'}

  Scenario: The page bar goes to a page
    When I read {'book-comic'}
    And I drag the page bar to the end
    Then the reader shows {'Page 5 of 5'}

  Scenario: A tap in the middle hides and shows the bars
    When I read {'book-comic'}
    Then the bars are shown
    When I tap the middle
    Then the bars are hidden
    When I tap the middle
    Then the bars are shown

  Scenario: The last page marks the book read
    When I read {'book-comic'}
    And I go to the last page
    And I stop a moment
    Then the server keeps page {5} of {'book-comic'}
    And the server has {'book-comic'} as read

  Scenario: Leaving saves at once, and returns to the book's page
    When I read {'book-comic'}
    And I turn the page with the right arrow key
    And I close the book
    Then the server is told only page {2} of {'book-comic'}

  Scenario Outline: <key> leaves too, and saves at once
    When I read {'book-comic'}
    And I turn the page with the right arrow key
    And I press {<key>}
    Then I am back on the book's page
    And the server is told only page {2} of {'book-comic'}

    Examples:
      | key         |
      | 'Esc'       |
      | 'Backspace' |

  Scenario: A download that fails can be tried again
    Given the book cannot be downloaded
    When I open the page of {'book-comic'}
    And I tap {'Read'}
    Then I see {'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.'}
    When the server is back
    And I tap Retry
    Then the reader shows {'Page 1 of 5'}

  Scenario: A book can be marked read from its page
    When I open the page of {'book-comic'}
    Then I see a button {'Mark as read'}
    When I mark it read
    Then the server has {'book-comic'} as read

  Scenario: The Books library is a grid of books, with how much is read
    Given {'book-comic'} is {60} percent read
    When I open the library {'view-books'}
    Then I see {'Test Comic'}
    And I see {'60% read'}
    And I see {'Test Book'}

  Scenario: Home continues reading, with how much is read
    Given {'book-comic'} is {40} percent read
    When I go home
    Then I see {'40% read'} in the {'Continue reading'} row
