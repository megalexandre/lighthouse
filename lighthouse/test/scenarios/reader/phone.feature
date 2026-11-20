Feature: Reading on a phone

  Android's Back closes the contents first, then leaves the book.

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
