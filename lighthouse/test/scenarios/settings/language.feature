Feature: Language
  The app's texts are in Brazilian Portuguese until the user picks
  another language in Settings; the choice is kept for the next start.

  Scenario: A new install speaks Brazilian Portuguese
    Given the app as installed
    When I open Settings
    Then I see the setting {'Idioma'}

  Scenario: Choosing English changes the texts, and is kept
    Given the app as installed
    When I open Settings
    And I choose the language {'English'}
    Then I see the setting {'Language'}
    When I restart the app
    And I open Settings
    Then I see the setting {'Language'}
