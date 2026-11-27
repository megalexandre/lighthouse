Feature: Highlights and notes

  An EPUB's text can be selected: held (then dragged) on touch, dragged
  over with a mouse. A menu over the selection highlights it in yellow,
  red or blue, writes a note on it, or copies it. A tap on a highlight
  brings the menu back, to change its colour or note, or remove it.
  Highlights are listed under Notes, beside the contents, and kept on this
  device only.

  Background:
    Given the app is signed in
    And the reader shows one page at a time

  Scenario: A word held is selected; a colour highlights it, kept for next time
    When I read {'book-epub'}
    And I hold the word {'first'}
    Then I see {'Add note'}
    When I highlight it {'red'}
    Then I do not see {'Add note'}
    And {'first'} is highlighted {'red'}
    When I close the book
    And I read it again
    And I open the notes
    Then I see {'first'}
    And I see {'Page 1'}

  Scenario: A mouse dragged over text selects it, without turning the page
    When I read {'book-epub'}
    And I drag the mouse from {'first'} to {'novel'}
    Then I see {'Copy'}
    And the reader shows {'Page 1 of 3'}
    When I copy it
    Then the clipboard holds {'first chapter of the test novel'}
    And I see {'Text copied'}
    And {'book-epub'} has no highlights

  Scenario: A note highlights the passage in yellow
    When I read {'book-epub'}
    And I hold the word {'test'}
    And I tap {'Add note'}
    And I write the note {'A good start'}
    Then {'test'} is highlighted {'yellow'}
    And {'test'} has the note {'A good start'}
    When I open the notes
    Then I see {'A good start'}

  Scenario: A tap on a highlight changes its colour, or removes it
    When I read {'book-epub'}
    And I hold the word {'first'}
    And I highlight it {'yellow'}
    And I tap the word {'first'}
    Then I see {'Remove highlight'}
    When I highlight it {'blue'}
    Then {'first'} is highlighted {'blue'}
    When I tap the word {'first'}
    And I tap {'Remove highlight'}
    Then {'book-epub'} has no highlights

  Scenario: Esc closes the menu, and the selection goes with it
    When I read {'book-epub'}
    And I hold the word {'first'}
    And I press {'Esc'}
    Then I do not see {'Add note'}
    And the book is still open

  Scenario: A highlight removed from the notes is gone from the page
    When I read {'book-epub'}
    And I hold the word {'first'}
    And I highlight it {'red'}
    And I open the notes
    And I tap the button {'Remove highlight'}
    Then I see a line {'No highlights yet'}
    And {'book-epub'} has no highlights

  Scenario: A comic's pages have no text to select, so no notes
    When I read {'book-comic'}
    And I open the contents
    Then I do not see {'Notes'}
