Feature: Reading
  The real app reads the fixture books and keeps the place on the server,
  on Jellyfin 12.4's scale: 10000 ticks a page for a comic, a fraction of
  10 million ticks for an EPUB.

  Background:
    Given I am signed in as a new user

  Scenario: A comic keeps its page, and opens there again
    When I read {'Test Comic'} from {'Books'}
    Then the reader shows {'Page 1 of 5'}
    When I turn the page with a swipe
    And I turn the page with the right arrow key
    Then the reader shows {'Page 3 of 5'}
    When I close the book
    Then I see {'Continue reading · 40%'}
    And the server keeps page {3} of {'Test Comic'}
    When I read it again
    Then the reader shows {'Page 3 of 5'}

  Scenario: An EPUB keeps the fraction read
    When I read {'Test Novel'} from {'Books'}
    Then the reader shows {'Page 1 of 3'}
    When I turn the page with the right arrow key
    Then the reader shows {'Page 2 of 3'}
    When I close the book
    Then the server keeps the fraction of {'Test Novel'} I read
