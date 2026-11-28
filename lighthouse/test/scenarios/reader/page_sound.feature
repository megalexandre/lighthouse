Feature: Page sound

  Pages sound like paper: dragged, they rub, louder the faster they move
  (still, they are quiet); each page that turns swishes once, whatever
  turned it. The sound can be turned off in the display settings, and
  stays off.

  Off in the app for now (the sounds do not sound like paper yet): no
  switch, no sound. The other scenarios turn it on, to keep it working.

  Background:
    Given the app is signed in
    And the reader shows one page at a time

  Scenario: For now there is no page sound, and nothing to turn it on
    When I read {'book-epub'}
    And I turn the page with the right arrow key
    And I drag the page {'quickly'} {600} px to the left
    Then the reader shows {'Page 3 of 3'}
    And the page swished {0} times
    And nothing rubbed
    When I open the display settings
    Then I do not see {'Paper sound as pages turn'}

  Scenario: A page dragged slowly rubs softly, and falls back without a swish
    Given the page sound is available
    When I read {'book-comic'}
    And I drag the page {'slowly'} {60} px to the left
    Then the paper rubbed {'softly'}
    And the paper is quiet
    And the page swished {0} times
    And the reader shows {'Page 1 of 5'}

  Scenario: A page dragged quickly rubs loudly, and swishes as it turns
    Given the page sound is available
    When I read {'book-comic'}
    And I drag the page {'quickly'} {600} px to the left
    Then the paper rubbed {'loudly'}
    And the paper is quiet
    And the page swished {1} times
    And the reader shows {'Page 2 of 5'}

  Scenario: Keys, the edges and the wheel swish once per page, without rubbing
    Given the page sound is available
    When I read {'book-comic'}
    And I turn the page with the right arrow key
    And I tap the {'right'} edge
    And I scroll the mouse wheel {'down'}
    Then the reader shows {'Page 4 of 5'}
    And the page swished {3} times
    And nothing rubbed

  Scenario: The last page does not swish when there is nothing to turn to
    Given the page sound is available
    When I read {'book-comic'}
    And I press {'End'}
    And I press {'Right'}
    Then the page swished {0} times

  Scenario: Turned off, pages turn in silence, and it stays off
    Given the page sound is available
    When I read {'book-epub'}
    And I open the display settings
    And I turn the page sound off
    And I close the display settings
    And I turn the page with the right arrow key
    And I drag the page {'quickly'} {600} px to the left
    Then the reader shows {'Page 3 of 3'}
    And the page swished {0} times
    And nothing rubbed
    And the page sound is kept off
