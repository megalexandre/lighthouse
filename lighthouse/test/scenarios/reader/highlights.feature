Feature: Highlights and notes

  An EPUB's text can be selected: held (then dragged) on touch, dragged
  over with a mouse. A menu over the selection highlights it in yellow,
  red or blue, writes a note on it, records a voice note, or copies it. A tap on a highlight
  brings the menu back, to change its colour or note, play or delete its
  voice note, or remove it.
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

  Scenario: A voice note is recorded on a selection, and played
    When I read {'book-epub'}
    And I hold the word {'first'}
    And I tap {'Record voice note'}
    Then I see {'Recording…'}
    When I wait {3} seconds
    Then I see {'0:03'}
    When I save the recording
    Then {'first'} is highlighted {'yellow'}
    And {'first'} has a voice note of {7} seconds
    And the file of {'voice-1.wav'} is kept
    When I tap the word {'first'}
    Then I see {'Voice note · 0:07'}
    When I tap the button {'Play voice note'}
    Then the voice note {'voice-1.wav'} plays
    When I tap the button {'Stop voice note'}
    Then no voice note plays

  Scenario: A voice note deleted is gone, file and all; the highlight stays
    When I read {'book-epub'}
    And I hold the word {'first'}
    And I highlight it {'red'}
    And I tap the word {'first'}
    And I tap {'Record voice note'}
    And I save the recording
    And I tap the word {'first'}
    And I tap the button {'Delete voice note'}
    Then {'first'} has no voice note
    And {'first'} is highlighted {'red'}
    And the file of {'voice-1.wav'} is deleted
    And I see {'Record voice note'}

  Scenario: A recording cancelled leaves nothing
    When I read {'book-epub'}
    And I hold the word {'first'}
    And I tap {'Record voice note'}
    And I tap {'Cancel'}
    Then {'book-epub'} has no highlights

  Scenario: Without a microphone, the reader says so
    Given the microphone cannot be used
    When I read {'book-epub'}
    And I hold the word {'first'}
    And I tap {'Record voice note'}
    Then I see a line {'Could not record'}
    And {'book-epub'} has no highlights

  Scenario: The notes play their voice notes; a highlight removed takes its voice note along
    When I read {'book-epub'}
    And I hold the word {'first'}
    And I tap {'Record voice note'}
    And I save the recording
    And I open the notes
    Then I see {'Voice note · 0:07'}
    When I tap the button {'Play voice note'}
    Then the voice note {'voice-1.wav'} plays
    When I tap the button {'Remove highlight'}
    Then {'book-epub'} has no highlights
    And no voice note plays
    And the file of {'voice-1.wav'} is deleted

  Scenario: A voice note has a play button on the page, which plays and stops it
    When I read {'book-epub'}
    And I hold the word {'first'}
    And I tap {'Record voice note'}
    And I save the recording
    And I tap the voice button of {'first'}
    Then the voice note {'voice-1.wav'} plays
    And I do not see {'Copy'}
    When I tap the voice button of {'first'}
    Then no voice note plays
    And I do not see {'Copy'}

  Scenario: A highlight without a voice note has no play button
    When I read {'book-epub'}
    And I hold the word {'first'}
    And I highlight it {'red'}
    And I tap the voice button of {'first'}
    Then no voice note plays
    And I do not see {'Remove highlight'}

  Scenario: A voice note deleted takes its play button with it
    When I read {'book-epub'}
    And I hold the word {'first'}
    And I tap {'Record voice note'}
    And I save the recording
    And I tap the word {'first'}
    And I tap the button {'Delete voice note'}
    And I press {'Esc'}
    And I tap the voice button of {'first'}
    Then no voice note plays
