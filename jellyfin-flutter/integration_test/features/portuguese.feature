Feature: Portuguese
  Brazilian Portuguese is the app's default language. Every other scenario
  runs in English; this one runs the app as installed. The server names
  languages in English ("Portuguese - AAC - Mono"): the app names them in
  its own language, from the track's language code.

  Scenario: As installed, the app and the track names are in Portuguese
    Given I am signed in as a new user with the app as installed
    Then I see {'Minhas mídias'}
    And I see {'Novidades em Movies'}
    When I play {'Test Movie (2020)'} from {'Movies'}
    And I pause the player
    And I open the audio tracks
    Then I see {'Inglês'}
    And I see {'Português'}
