Feature: Search
  The real app against the test server: search finds the Test Movie as it
  is typed, and the result opens its page.

  Scenario: Typing finds the movie, which opens its page
    Given I am signed in as a new user
    When I search for {'test mov'}
    And I open the result {'Test Movie (2020)'}
    Then I see the page of {'Test Movie (2020)'}
