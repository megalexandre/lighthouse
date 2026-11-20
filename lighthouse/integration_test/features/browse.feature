Feature: Browsing
  The real app against the test server's fixture library: home lists the
  libraries; one opens as a grid, a card opens its page, and a series goes
  down to its seasons and episodes.

  Background:
    Given I am signed in as a new user

  Scenario: Home, the Movies library, the Test Movie, and back
    Then I see the libraries {'Movies'}, {'Shows'} and {'Music'}
    And I see {'Latest in Movies'}
    When I open the {'Movies'} library
    Then the library shows {'Test Movie (2020)'}
    And the library shows {'HEVC Movie (2021)'}
    When I open {'Test Movie (2020)'}
    Then I see the page of {'Test Movie (2020)'}
    And I see a line {'2020 · 10s'}
    And its poster comes from the server
    When I go back
    Then I am in the library
    When I go back
    Then I am home

  Scenario: From the Shows library down to an episode
    When I open the {'Shows'} library
    And I open {'Test Show'}
    Then I see the page of {'Test Show'}
    When I open {'Season 1'}
    Then I see {'Episodes'}
    And {3} episodes are listed
    When I open episode {2}
    Then I see a line {'S1:E2'}
    And there is a link to the series
