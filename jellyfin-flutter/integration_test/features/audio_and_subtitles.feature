Feature: Audio and subtitles
  The Test Movie has English and Portuguese audio and an external
  Portuguese subtitle. The language chosen in Settings is kept on the
  server and is what mpv plays; the player switches tracks on request.

  Background:
    Given I am signed in as a new user

  Scenario: Portuguese audio chosen in Settings is what the movie plays
    When I choose {'Portuguese'} as the audio language in Settings
    Then the server keeps {'por'} as the audio language
    When I play {'Test Movie (2020)'} from {'Movies'}
    Then mpv plays the {'por'} audio track

  Scenario: Switching the audio and the subtitle in the player
    When I play {'Test Movie (2020)'} from {'Movies'}
    Then mpv plays the {'eng'} audio track
    And mpv checks HTTPS certificates
    When I pause the player
    And I switch the audio to Portuguese
    Then mpv plays the {'por'} audio track
    When I turn on the external Portuguese subtitle
    Then mpv shows the external subtitle line {'Português subtitle one'}
    When I turn the subtitles off
    Then mpv shows no subtitle
