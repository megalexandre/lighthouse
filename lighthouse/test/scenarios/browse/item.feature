Feature: Item page

  An item's page shows its title, facts and overview. A series lists its
  seasons, a season its episodes, an album its tracks; an episode links
  back to its series. What fails to load can be tried again.

  Background:
    Given the app is signed in

  Scenario: A movie: title, facts and overview
    When I open the page of {'Test Movie'}
    Then I see the page of {'Test Movie'}
    And I see {'2020 · 1h 32m · PG'}
    And I see {'A movie made for tests.'}
    And there is no link to a series

  Scenario: From a series down to an episode, and back up
    When I open the page of {'Test Show'}
    Then I see {'Seasons'}
    When I open {'Season 1'}
    Then I see the page of {'Season 1'}
    And I see {'1. Episode 1'}
    And I see {'2. Episode 2'}
    And I see {'3. Episode 3'}
    When I open {'2. Episode 2'}
    Then I see the page of {'Episode 2'}
    And I see {'S1:E2 · 45m'}
    When I open the series
    Then I see the page of {'Test Show'}

  Scenario: An album lists its tracks
    When I open the page of {'Test Album'}
    Then I see the page of {'Test Album'}
    And I see {'Test Artist'}
    And I see {'Track 1'}
    And I see {'Track 2'}
    And each track shows {'3m'}

  Scenario: The picture and the sound show as badges
    Given {'Test Movie'} is in 1080p, with 5.1 sound and subtitles
    When I open the page of {'Test Movie'}
    Then I see the badges {'1080P'}, {'5.1'} and {'CC'}

  Scenario: Seasons that fail to load do not hide the series
    Given the seasons cannot be loaded
    When I open the page of {'Test Show'}
    Then I see the page of {'Test Show'}
    When the server answers again
    And I tap Retry
    Then I see {'Season 1'}

  Scenario: A page that fails to load can be tried again
    Given the item cannot be loaded
    When I open the page of {'Test Movie'}
    Then I see {'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.'}
    When the server answers again
    And I tap Retry
    Then I see the page of {'Test Movie'}
