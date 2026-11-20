Feature: EPUB

  An EPUB is laid out for the sheet (here, a page per chapter) and turned
  like the other books. Its place is the fraction read, so a new layout,
  for another window size or bigger type, keeps it. The contents jump to
  a chapter; bookmarks are kept on this device; links go to their target,
  and back. The reader's theme and type are kept for the next book.

  Background:
    Given the app is signed in

  Scenario: Laid out a page per chapter; the place kept is the fraction read
    When I read {'book-epub'}
    Then the reader shows {'Page 1 of 3'}
    When I turn the page with the right arrow key
    Then the reader shows {'Page 2 of 3'}
    When I stop a moment
    Then the server keeps a fraction of {'book-epub'}
    When I close the book
    And the server gives that place back
    And I read it again
    Then the reader shows {'Page 2 of 3'}

  Scenario: Left halfway, it opens on the middle chapter
    Given {'book-epub'} was left halfway
    When I read {'book-epub'}
    Then the reader shows {'Page 2 of 3'}

  Scenario: Another window size lays it out again, at the same place
    When I read {'book-epub'}
    And I turn the page with the right arrow key
    And the window becomes {900} by {1400}
    Then the reader shows {'Page 2 of 3'}

  Scenario: The contents list the chapters, and one jumps there
    When I read {'book-epub'}
    And I open the contents
    Then I see {'Chapter One'}
    And I see {'Chapter Two'}
    When I tap {'Chapter Three'}
    Then the contents are closed
    And the reader shows {'Page 3 of 3'}
    When I press {'Left'}
    Then the reader shows {'Page 2 of 3'}

  Scenario: A book without contents says so
    When I read {'book-comic'}
    And I open the contents
    Then I see {'This book has no table of contents.'}

  Scenario: A bookmarked page is kept, listed, and removed
    When I read {'book-epub'}
    And I press {'Right'}
    And I bookmark the page
    Then I see a button {'Remove bookmark'}
    When I press {'Right'}
    Then I see a button {'Bookmark this page'}
    When I open the bookmarks
    Then I see {'Page 2'}
    And I see {'Chapter Two'}
    When I tap {'Page 2'}
    Then the reader shows {'Page 2 of 3'}
    When I close the book
    And I read it again
    And I open the bookmarks
    And I tap the button {'Remove bookmark'}
    Then I see a line {'No bookmarks yet'}
    And {'book-epub'} has no bookmarks

  Scenario: The bookmark button takes the page's bookmark off again
    When I read {'book-epub'}
    And I press {'Right'}
    And I bookmark the page
    Then I see a button {'Remove bookmark'}
    When I bookmark the page
    Then I see a button {'Bookmark this page'}
    And {'book-epub'} has no bookmarks

  Scenario: Bookmarks that cannot be read: the book opens all the same, without them
    Given the bookmarks cannot be read
    When I read {'book-epub'}
    Then the reader shows {'Page 1 of 3'}
    When I open the bookmarks
    Then I see a line {'No bookmarks yet'}

  Scenario: A bookmark that cannot be saved still marks the page while the book is open
    Given the bookmarks cannot be saved
    When I read {'book-epub'}
    And I press {'Right'}
    And I bookmark the page
    Then I see a button {'Remove bookmark'}
    And {'book-epub'} has no bookmarks

  Scenario: The theme changes the desk and the paper, and is kept
    When I read {'book-epub'}
    Then the desk is {'light'}
    When I pick the {'dark'} theme
    Then the desk is {'dark'}
    And the paper is {'dark'}
    When I close the display settings
    And I close the book
    And I read it again
    Then the desk is {'dark'}

  Scenario: What was set before applies from the start
    Given the reader was set to {'sepia'}, {24} px, sans serif
    When I read {'book-epub'}
    Then the desk is {'sepia'}
    And the type of {'book-epub'} is {24} px
    And the type of {'book-epub'} is sans serif

  Scenario: Bigger type lays the book out again, at the same place
    When I read {'book-epub'}
    And I press {'Right'}
    And I open the display settings
    Then I see {'18 px'}
    When I make the type bigger
    And I make the type bigger
    Then I see {'22 px'}
    And the type of {'book-epub'} is {22} px
    And the reader shows {'Page 2 of 3'}

  Scenario: Sans serif type is laid out at once
    When I read {'book-epub'}
    And I open the display settings
    And I pick sans serif
    Then the type of {'book-epub'} is sans serif

  Scenario: A comic has the themes, but no type settings
    When I read {'book-comic'}
    And I open the display settings
    Then I can pick the {'sepia'} theme
    And there are no type settings

  Scenario: A link goes to its target, and back
    Given a book {'book-links'} with a link to a note two pages on
    When I read {'book-links'}
    Then the reader shows {'Page 1 of 3'}
    When I follow the link
    Then the reader shows {'Page 3 of 3'}
    And I see {'Back to page 1'}
    When I go back from the link
    Then the reader shows {'Page 1 of 3'}
    And I do not see {'Back to page 1'}
