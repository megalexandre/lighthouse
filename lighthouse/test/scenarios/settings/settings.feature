Feature: Settings

  Settings shows what is set. Languages, subtitles and next episode
  autoplay are kept on the server, for every client; the quality limit and
  the looks only on this device. A save that fails says so. Themes come
  built in or from the user's folder, which the app watches.

  Background:
    Given the app is signed in

  Scenario: Settings opens from home, with what is set
    Given my audio language on the server is {'por'}
    And my subtitles on the server are {'Always'}
    And my quality limit is {4} Mbps
    When I open Settings from home
    Then I see {'4 Mbps'}
    And the audio language reads {'Portuguese'}
    And I see {'Always'}
    And I see {'alice'}

  Scenario: Languages, subtitles and autoplay go to the server
    When I open Settings
    And I type {'port'} in the audio language and pick {'Portuguese'}
    Then the server keeps my audio language as {'por'}
    When I pick {'Never'} in the {'subtitles'} setting
    Then the server keeps my subtitles as {'Never'}
    When I type {'file'} in the audio language and pick {"The file's default"}
    Then the server keeps no audio language
    When I turn next episode autoplay off
    Then the server keeps next episode autoplay off

  Scenario: The quality is kept on this device
    When I open Settings
    And I pick {'2 Mbps'} in the {'quality'} setting
    Then this device keeps the quality at {'2 Mbps'}
    When I pick {'Maximum'} in the {'quality'} setting
    Then this device keeps the quality at {'Maximum'}

  Scenario: A save that fails says so
    Given the server cannot save settings
    When I open Settings
    And I type {'port'} in the audio language and pick {'Portuguese'}
    Then I see {'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.'}

  Scenario: Prime in dark at first; another mode and theme are kept
    Given no look was chosen yet
    When I open Settings
    Then the app shows {'Prime'} in {'dark'} mode
    When I pick the {'light'} mode
    Then the app shows {'Prime'} in {'light'} mode
    When I pick {'Lanterna'} in the {'theme'} setting
    Then the app shows {'Lanterna'} in {'light'} mode
    When I restart the app
    And I open Settings
    Then the app shows {'Lanterna'} in {'light'} mode

  Scenario: A theme from my folder can be picked; one that cannot be read is reported
    Given my themes folder has {'Mine'} with the accent {'#ff8800'}
    And a file {'broken.json'} that cannot be read
    When I open Settings
    And I pick {'Mine (your folder)'} in the {'theme'} setting
    Then the accent is {'#ff8800'}
    And I see {'1 theme issue'}
    When I open the theme issues
    Then I see a line {'broken.json: not used'}

  Scenario: Saving my theme's file changes the app as it runs
    Given my themes folder has {'Mine'} with the accent {'#00a4dc'}
    And {'Mine'} was chosen
    When I open Settings
    Then the accent is {'#00a4dc'}
    When my themes folder has {'Mine'} with the accent {'#22cc66'}
    Then the accent is {'#22cc66'}

  Scenario: The player stays dark in light mode
    Given the {'light'} mode was chosen
    When I open an episode
    Then the screen is {'light'}
    When I play the episode
    Then the player is {'dark'}
