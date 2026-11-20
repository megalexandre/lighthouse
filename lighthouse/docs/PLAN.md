# Plano: Lighthouse, cliente desktop Jellyfin em Flutter (`/workspace/lighthouse`)

## Contexto

Hoje o `jellyfin-desktop` é um shell Qt WebEngine: ele carrega o jellyfin-web e intercepta o playback via
`native/nativeshell.js` + `mpvVideoPlayer.js`, que mandam o vídeo para o libmpv (`src/player/PlayerComponent.cpp`).
Por cima disso há MPRIS, input maps (`resources/inputmaps/*.json`), controle de energia e troca de refresh rate.

O objetivo é um cliente **com UI nativa Flutter** que fala direto com a API REST do servidor (12.4, já rodando no
dev container em `http://jellyfin:8096`) e toca mídia com **media_kit (libmpv)**. Linux primeiro.
**Requisitos obrigatórios: testes de integração e planejamento por fases**, com cada fase fechada por testes.

Decisões já tomadas com o usuário:
- UI nativa Flutter + API REST (sem WebView).
- Linux é o alvo do MVP; Windows/macOS depois (código sem dependência de plataforma fora de `platform/`).
- MVP = núcleo de playback; paridade completa (MPRIS, gamepads, refresh rate...) vem depois.
- Código em `/workspace/lighthouse`, **versionado pelo repo git da raiz** (não é ignorado no `.gitignore`).
- `related-repos/jellyfin/` e `related-repos/jellyfin-desktop/` ficam só como referência (clonados e atualizados a cada início do container por `.devcontainer/related_repos.sh`).

## Stack

| Área | Escolha | Por quê |
|---|---|---|
| Estado / DI | `flutter_riverpod` | overrides de provider tornam fácil trocar API real por fake nos testes |
| Rotas | `go_router` | rotas declarativas, redirect por estado de login |
| HTTP | `dio` | interceptors (header de auth, log, retry) |
| Modelos | `freezed` + `json_serializable` | DTOs imutáveis, só dos campos que usamos |
| Player | `media_kit`, `media_kit_video`, `media_kit_libs_linux` | libmpv, mesmo motor do desktop atual |
| Token | `flutter_secure_storage` (libsecret já está no Dockerfile) | |
| Janela | `window_manager` | fullscreen, título |
| Testes | `flutter_test`, `integration_test`, `bdd_widget_test` (cenários), fakes à mão (`test/support/fakes.dart`) | |
| Lint | `flutter_lints` + regras estritas no `analysis_options.yaml` | |

Cliente da API **escrito à mão** (só os endpoints usados), não gerado do OpenAPI: o gerador precisa de Java e gera
milhares de arquivos. Para não perder a garantia de contrato, um **teste de contrato** (abaixo) compara cada endpoint e
campo usado contra o `/api-docs/openapi.json` do servidor de teste (já confirmado que responde 200).

## Estrutura

```
lighthouse/
  lib/
    main.dart  app.dart  router.dart
    core/         config, logging, device id, erros (Failure), formatação de ticks
    api/          JellyfinApi (dio), AuthInterceptor, endpoints por área:
                  system.dart users.dart items.dart playback.dart sessions.dart
      models/     DTOs freezed (BaseItemDto, MediaSourceInfo, UserDto, PlaybackInfoResponse...)
    features/
      server/     conectar a um servidor (URL, valida /System/Info/Public)
      auth/       login, sessão persistida, logout
      home/       Continuar assistindo, Próximos, Recentes
      library/    bibliotecas, grade paginada, filtros/ordenação básicos
      item/       detalhes de filme / série / temporada / episódio / álbum
      player/     PlayerController (media_kit), OSD, faixas, PlaybackReporter
      search/  settings/
      (cada feature: data/ repositório, application/ providers, presentation/ widgets)
  test/                    unitários + widget (sem rede, API fake)
  test/server/             testes do cliente da API contra o servidor real (tag `server`)
  integration_test/        fluxos do app real em Linux sob Xvfb, contra o servidor real
  packages/jellyfin_test_server/   bootstrap/limpeza do servidor de teste (dev_dependency por path)
  fixtures/media/          mídia de teste gerada (pequena, commitada)
  tool/                    gen_fixtures.sh, check.sh (gate local completo)
  dart_test.yaml           tags: server, slow
```

## Estratégia de testes (o centro do plano)

Quatro camadas; toda fase só termina com as quatro verdes no `tool/check.sh`.

1. **Unitários** (`test/`): parsing de DTOs com JSON real capturado do 12.4, header `Authorization: MediaBrowser ...`,
   conversão de ticks, montagem de URL de stream, escolha de direct play vs transcode, lógica do `PlaybackReporter`
   (start/progress a cada 10 s/pause/stop) com relógio fake.
2. **Widget** (`test/`): cada tela com repositórios fake via override do Riverpod: estados loading/erro/vazio/dados,
   navegação, atalhos de teclado do player.
3. **Cliente da API x servidor real** (`test/server/`, `flutter test --tags server`): login, views, `/Items` paginado,
   `PlaybackInfo`, reportar progresso e conferir `UserData.PlaybackPositionTicks`, marcar assistido.
   Inclui o **teste de contrato**: baixa o `openapi.json` e valida a lista de (método, rota, campos) que o cliente usa;
   quebra se um upgrade de servidor mudar algo.
4. **Integração do app** (`integration_test/`, `xvfb-run flutter test integration_test -d linux`):
   app real, servidor real, mpv com `vo=libmpv`, decodificação por software e `ao=null` (sem som no CI).
   Fluxos: conectar+login; navegar até um filme; tocar, esperar posição > 2 s, pausar, sair, conferir pela API que o
   progresso foi salvo; reabrir e "Retomar" começa no ponto salvo; trocar faixa de áudio/legenda; próximo episódio.

### Cenários de comportamento (Gherkin)

Comportamentos de usuário descritos em `.feature`, em inglês e em Gherkin padrão, com o pacote `bdd_widget_test`
(fixado na 3.0.4). A etapa de geração de código do `check.sh` (`build_runner`, que no `build.yaml` também lê
`integration_test/`) transforma cada `x.feature` num `x_test.dart` ao lado, um `testWidgets` por cenário. Esse arquivo
é gerado: não se edita, é commitado e fica fora da checagem de formatação. Os passos ficam na pasta `step/` da feature,
um arquivo por frase, e o gerador só cria o esqueleto de um passo novo, sem sobrescrever os existentes. O estado que os
passos compartilham fica em `step/world.dart`; o que roda em volta de cada cenário fica em `hook/hooks.dart` (`addHooks`
no `build.yaml`; um por pasta). O `After:` não é usado: outras ferramentas o leem como descrição.

Dois lugares:
- **`test/scenarios/<área>/`**, com fakes (`TestApp`): rápido, sem rede. Os fluxos de usuário de todas as telas:
  - `auth/`: `connect`, `login` (sair, trocar de servidor, reabrir já logado).
  - `browse/`: `home`, `library`, `item`, `cards` (assistido, progresso, hover, painel do Prime) e `prime` (barra de
    abas, carrossel, busca, menu de perfil, setas das fileiras). Uma pasta só, porque navegam pelas mesmas telas e
    dividem os passos.
  - `player/`: `playing` (play, retomar, pausa, setas, OSD, fim, erro), `playing_on` (próximo episódio, Next e
    Previous, álbum, tela cheia e volume entre episódios, autoplay desligado), `controls` (menus e teclas de áudio e
    legenda, volume, tela cheia, transcode), `on_screen_controls` (capítulos, ±10 s, velocidade, Esc), `up_next`,
    `keyboard_tracks` e `connection_lost` (playback interrompido, reporte enviado na volta do servidor).
  - `reader/`: `reading` (quadrinho: virar página, salvar o lugar, lido, biblioteca e home), `epub` (diagramação,
    sumário, marcadores, temas, fonte, links) e `reading_offline`.
  - `search/`, `server/connection` (o banner) e `settings/` (`settings`, `language`).

  Os testes Dart ficam em `test/features/<área>/`: só o que nenhum usuário vê (quantas vezes e com que páginas o
  servidor é chamado, o formato de um arquivo guardado, funções puras, a mecânica e os goldens da virada de página).
- **`integration_test/features/`**, com o app real sob Xvfb contra o servidor de teste. Uma pasta só, para os passos
  ("I am signed in as a new user", "I play {..} from {..}"...) servirem a todas as features. O `Hooks.beforeAll` carrega
  o libmpv e prepara o servidor; cada cenário cria o seu usuário no primeiro passo; o `Hooks.afterEach` sai do player ou
  do leitor como o usuário sairia (para o último reporte chegar ao servidor) e desmonta o app. Features: `login`
  (senha certa, errada, sair, sessão encerrada fora do app), `browse` (home → biblioteca → item; série → temporada →
  episódio), `search`, `connection` (o servidor some atrás de um proxy e volta), `watching` (retomar, assistido no
  fim), `play_on` (próximo episódio, próxima faixa), `audio_and_subtitles` (idioma em Settings, troca de faixa e
  legenda no player), `portuguese` e `reading` (página do quadrinho, fração do EPUB). Ficaram em Dart só o PDF
  desenhado pelo PDFium (`books_flow_test`, confere os pixels) e o keyring.

Para rodar: `tool/scenarios.sh` (todas), `tool/scenarios.sh <arquivo> ["parte do nome"]` (uma feature; de um arquivo
de `step/` ou `hook/`, as features da pasta), ou as tasks do VS Code "scenarios (all features)", "scenarios (this
feature)" (a feature aberta no editor) e "scenarios (regenerate on save)". Todas regeneram os testes antes de rodar; as
de `integration_test/` pedem o servidor de teste e usam o build lock. Os testes de unidade e de tela continuam em Dart
puro; o Gherkin fica para os fluxos de usuário.

### Servidor de teste isolado

- Novo serviço `jellyfin-test` no `docker-compose.yml` (mesma imagem `jellyfin/jellyfin:12.4`), `/config` em **tmpfs**
  (zera a cada `up`), sem porta publicada, mídia de `../lighthouse/fixtures/media`. Env no app:
  `JELLYFIN_TEST_URL=http://jellyfin-test:8096`. O servidor `jellyfin` de desenvolvimento continua intocado.
- `packages/jellyfin_test_server` faz o bootstrap **idempotente** pela API:
  espera `/System/Info/Public`; se `StartupWizardCompleted=false` → `POST /Startup/Configuration`, `POST /Startup/User`,
  `POST /Startup/Complete`; cria bibliotecas (`POST /Library/VirtualFolders` para Filmes, Séries, Música); espera o scan
  terminar (polling de `/Items` até a contagem esperada).
- **Isolamento entre testes**: cada teste que altera estado cria um usuário novo (`POST /Users/New`); assim
  progresso/assistido nunca vaza entre testes, sem precisar reiniciar o container. Os usuários **não são apagados**:
  o 12.4 reaproveita o id interno do último usuário apagado, e o estado de assistido dele vai junto para o próximo
  (visto no F2). Como o servidor de teste é tmpfs, eles somem no restart.

### Fixtures de mídia

A mídia atual (`resources/testmedia/*.h264`) é vídeo cru, sem áudio, legenda nem metadados: insuficiente.
`tool/gen_fixtures.sh` (ffmpeg, determinístico, ~2 MB no total, commitado) gera:
- `movies/Test Movie (2020)/` — MKV 10 s, H.264 + 2 faixas de áudio (eng/por) + legenda SRT embutida + `.srt` externa.
- `shows/Test Show/Season 01/` — 3 episódios `S01E01..03` (próximo episódio / Next Up).
- `music/Test Artist/Test Album/` — 2 faixas com tags.
- um HEVC 10-bit curto (força o caminho de transcode/compatibilidade).

## Mudanças no dev container (por cima das alterações não commitadas que já existem em `.devcontainer/`)

- `Dockerfile`: adicionar `ffmpeg` à lista do apt.
- `docker-compose.yml`: serviço `jellyfin-test` + `JELLYFIN_TEST_URL` no `app` (+ `depends_on`).
- `postCreate.sh`: caminho do projeto `jellyfin-desktop/flutter` → `jellyfin-flutter` (depois renomeado para `lighthouse`).
- `README.md`: seção "Testes" (camadas, como rodar, servidor de teste).

## Fases

Cada fase = um ou mais commits no repo raiz; "pronto" = critérios de teste abaixo verdes no `tool/check.sh`
(`dart format --set-exit-if-changed`, `flutter analyze`, `flutter test`, `--tags server`, `integration_test` sob Xvfb).

**F0 — Fundação**
`flutter create --platforms=linux jellyfin-flutter`, lint, estrutura de pastas, dev container, fixtures,
`jellyfin_test_server`, `tool/check.sh`, workflow de CI em `.github/workflows/flutter.yml` (fica pronto para quando o
repo tiver remote; hoje não há).
Pronto: smoke `integration_test` abre o app sob Xvfb; teste `server` faz o bootstrap e encontra as fixtures.

**F1 — API, servidor e login**
`JellyfinApi`, `AuthInterceptor` (Client/Device/DeviceId/Version/Token), DeviceId estável salvo localmente;
telas Conectar servidor e Login; sessão em secure storage; redirect do router; logout.
Pronto: testes de contrato + login (certo/senha errada/servidor fora); integração "conectar, logar, reabrir o app já logado".

**F2 — Navegação**
`/UserViews`, `/Items` paginado (rolagem infinita), `/Items/{id}`, séries → temporadas → episódios,
home (`/UserItems/Resume`, `/Shows/NextUp`, `/Items/Latest`), imagens (`/Items/{id}/Images/...` com tamanho pedido).
Pronto: widget tests de cada tela; integração "home → biblioteca Filmes → detalhes do Test Movie".

**F3 — Playback (núcleo do MVP)**
`PlaybackInfo` com DeviceProfile (portar `getDeviceProfile()` de `jellyfin-desktop/native/nativeshell.js`: mpv toca
quase tudo → direct play amplo, transcode só quando o servidor exigir); stream com header de auth no `Media` do
media_kit; seleção de faixa de áudio/legenda (embutida e externa); OSD (seek, volume, faixas, fullscreen);
atalhos de teclado portados de `resources/inputmaps/keyboard.json`; `PlaybackReporter`
(`/Sessions/Playing`, `/Progress`, `/Stopped`); retomar; marcar assistido; próximo episódio; player de áudio para música.
Pronto: todos os fluxos de playback da camada 4 acima.

**F4 — Fechamento do MVP**
Busca (`/Items?searchTerm=`), configurações (qualidade máxima/bitrate, idioma preferido de áudio/legenda),
tratamento de erros e reconexão, logs em arquivo, build release `flutter build linux` + empacotamento (AppImage).
Pronto: integração de busca e preferência de idioma aplicada no playback; build release roda os testes de integração.
Ajuste feito no F4c: um build release não pode ser conduzido por teste (não tem VM service), então os testes de
integração rodam em **profile** (`tool/profile_test.sh`: AOT, compilado como o release), e o AppImage release
(`tool/build_appimage.sh`) passa por um teste de fumaça (abre sob Xvfb e grava o log).

**Livros (pedido depois do MVP, em fases L)**
Estilo Google Play Livros: biblioteca de capas, "Continue reading", leitor página a página (deslizar, tocar nas
bordas, teclado), progresso no servidor.
- **L1 (feito):** navegação de livros (tipo `Book`, biblioteca `books`, busca, home) e leitor de **PDF**
  (pdfrx/PDFium) e **quadrinhos CBZ** (zip de imagens). Arquivo baixado uma vez para o cache local
  (`/Items/{id}/Download`). Posição em `POST /UserItems/{id}/UserData`: o 12.4 dá a PDF/CBZ uma "duração" de
  10000 ticks por página e calcula a % lida com ela; a posição segue essa escala (`reading_position.dart`), então
  a % do servidor e outros clientes concordam. Chegar à última página marca como lido. Fixtures: um PDF, um CBZ e
  um EPUB pequenos e determinísticos (`tool/gen_books.py`).
- **L2 (feita):** EPUB paginado, com paginador próprio (no Linux o Flutter não tem WebView confiável).
  `reader/data/epub/`: `epub_book.dart` lê o pacote (container → OPF → spine) e converte cada capítulo
  (XHTML lido com tolerância, pelo pacote `html`) em blocos: parágrafos, títulos, citações, listas, `pre`,
  imagens, linhas; negrito/itálico/monoespaçado. O CSS da editora é ignorado (exceto centralizar): o leitor
  define a tipografia. `epub_layout.dart` diagrama cada parágrafo uma vez na largura da folha e corta entre
  linhas para as páginas (cada capítulo abre uma página; imagens cabem na página); as páginas são desenhadas
  pelo próprio paginador, então a virada de página funciona igual. O lugar é contado em caracteres, que não
  mudam com o tamanho: redimensionar a janela repagina e mantém o trecho. Posição no servidor: o 12.4 dá ao
  EPUB "duração" de 10^7 ticks e guarda a **fração lida** nessa escala (a mesma do jellyfin-web).
  Abrir, descompactar e ler o EPUB acontece num isolate.
  No Android, WebView + epub.js continua sendo alternativa, se o paginador não bastar.
- **Virada de página (feita, página única):** guiada pelo dedo como no Play Livros. A folha (no formato da página,
  sobre um fundo neutro) enrola num cilindro (`page_curl/curl_geometry.dart`, Dart puro e testado) desenhado por um
  shader de fragmento (`shaders/page_curl.frag`): verso com a tinta da própria página vista pelo papel (espelhada,
  fraca), sombra na curva, brilho na crista, sombra projetada que some ao assentar; presa na lombada; soltar antes do
  meio volta, depois (ou com flick) vira, com ease-out; metade esquerda traz a anterior; teclado e toques nas bordas
  fazem a mesma animação; "reduzir animações" troca sem animar. Quadros de referência em
  `test/features/reader/goldens/` (conferidos a olho ao mudar o shader: `flutter test --update-goldens`).
  Falta: modo de duas páginas com lombada (paisagem/tablet).
- **L3 (feita):** sumário, links internos, fonte, temas e marcadores.
  - Sumário: no EPUB vem do nav (EPUB 3) ou do NCX (EPUB 2); sem nenhum dos dois, são os capítulos que começam
    com título. No PDF vem do outline do PDFium; quadrinhos não têm. Os itens e os marcadores são frações do livro
    (`EpubBook.offsetOf`: caracteres até a âncora), então continuam certos depois de repaginar.
  - Links internos (EPUB): tocar no link vai até a âncora, e um botão "Back to page N" volta. Links externos são
    ignorados.
  - Fonte (EPUB): 8 tamanhos de 14 a 32 px, serifa ou sem serifa. Mudar repagina e mantém o trecho.
  - Temas claro, sépia e escuro, para todos os formatos:
    - EPUB: o texto é diagramado em preto e pintado na tinta do tema, então trocar de tema não repagina.
    - PDF: recolorido por matriz (branco vira papel, preto vira tinta); no tema claro fica intacto.
    - Quadrinhos e imagens mantêm as cores.
    - Na virada de página, o brilho da crista diminui no papel escuro.
  - Preferências e marcadores ficam só neste aparelho, num arquivo JSON em
    `~/.local/share/<app>/reader/` (`FileKeyValueStore`); marcadores por servidor e livro. O Jellyfin não tem onde
    guardá-los.
- PDFium vem de `bblanchon/pdfium-binaries` (versão fixa `chromium/8125`), baixado no build pelo hook do
  `pdfium_dart`, sem conferência de hash.

**T1 — Temas por design system (feita).** O visual vem do `tokens.json` do Claude Design: o Lanterna vem
embutido, e outros temas podem ser colocados numa pasta do usuário, recarregados sem recompilar. A escolha de tema e
modo fica em Settings, e o player é sempre escuro. Detalhes, fluxo de modificação e a tabela de tokens estão em
[THEMES.md](THEMES.md). 
**T2 — Componentes do Lanterna (feita).** Button, foco, Badge, MediaCard e o player completo (ControlButton,
SeekBar com buffer, capítulos e prévia por trickplay, SettingsMenu com velocidade, UpNext, ±10 s). O vídeo de teste
ganhou capítulos, e o servidor de teste gera trickplay. Os detalhes estão em [THEMES.md](THEMES.md).

**I — Internacionalização.** Textos do app em português do Brasil (o padrão) e inglês, com o
`flutter gen-l10n` oficial: um arquivo ARB por idioma em `lib/l10n/` (`app_en.arb` é o modelo, com as chaves, as
descrições e os parâmetros; `app_pt.arb` tem as traduções, e `app_pt_BR.arb` só declara o locale, porque o
gen-l10n exige o idioma base). O código usa `context.l10n.<chave>`; a classe gerada fica em `lib/l10n/generated/`
(commitada, fora da análise). As traduções do próprio Material vêm do `material_ui`.
- **I1 (feita):** a base. O idioma fica no `Appearance` (Settings → Appearance → Language), guardado só depois de
  escolhido; até lá vale `defaultLanguageProvider` (pt_BR). Os testes sobrescrevem esse padrão com inglês, então os
  `find.text` e os `.feature` seguem em inglês. O `check.sh` roda o gen-l10n e falha se alguma chave do inglês não
  tiver tradução. Cenário `test/scenarios/settings/language.feature`.
- **I2 (feita):** os textos de todas as telas nos ARBs (~165 chaves). Os `Failure` não têm mais texto de tela: a
  tela os descreve pelo tipo (`describe(l10n)` em `lib/l10n/failure_text.dart`, um `switch` sobre a sealed class, então
  um tipo novo sem tradução não compila); o `detail` segue só no log. `formatRuntime`, `cardSubtitle`,
  `episodeNumber`, `trackLabel`, `qualityBadges` e `rateLabel` recebem o `AppLocalizations`. Plurais no ICU
  (temporadas, horas/minutos/segundos do leitor de tela, problemas de tema); "S1:E2" vira "T1:E2", "1.5×" vira "1,5×".
  Nos testes, `en` (test/support/fakes.dart) é o inglês para comparar com a tela: `find.text(failure.describe(en))`.
  Ficam fora: nomes de teclas (Esc, Shift+P), textos de protocolo e de log.
- **I3 (feita):**
  - `integration_test/features/portuguese.feature` roda o app real como instalado (pt_BR) e confere a home e as
    faixas de áudio em português.
  - Nomes de idioma: o servidor manda o rótulo da faixa em inglês ("Portuguese - AAC - Mono"). O app monta o seu a
    partir do código ISO 639 da faixa: o nome do idioma no idioma do app, e o título da faixa só quando não é só o nome
    do idioma ("Inglês · Comentário do diretor"). O formato ("AAC", "SRT") e "Forçada" vão no detalhe. Sem idioma
    conhecido, fica o rótulo do servidor. As listas de idioma de Configurações usam os mesmos nomes, em ordem
    alfabética sem acentos.
  - A tabela (`lib/l10n/language_names.dart`) é gerada por `tool/gen_language_names.py`: nomes do Unicode CLDR
    (versão fixa no script) para os códigos do `iso6392.txt` do servidor (B, T e de duas letras). Um idioma novo no
    app entra em `APP_LANGUAGES` do script.
Títulos, sinopses e gêneros vêm do servidor, no idioma dos metadados do Jellyfin: não são do app.

**F5+ — Pós-MVP (planejar em detalhe ao chegar)**
MPRIS (D-Bus), gamepads/remotes (demais inputmaps), WebSocket de sessão (controle remoto a partir de outro cliente),
múltiplos servidores/perfis, troca de refresh rate e passthrough de áudio, Windows e macOS.

## Arquivos de referência a reaproveitar (lógica, não código)

- `jellyfin-desktop/native/nativeshell.js` — `getDeviceProfile()` e lista de features.
- `jellyfin-desktop/native/mpvVideoPlayer.js` — como o web client conduz o mpv (faixas, seek, eventos).
- `jellyfin-desktop/src/player/PlayerComponent.cpp` — opções de mpv usadas (hwdec, cache, áudio).
- `jellyfin-desktop/resources/inputmaps/keyboard.json` — atalhos.
- `jellyfin/Jellyfin.Api/Controllers/` — fonte da verdade dos endpoints (atenção: fonte é 13.x, servidor é 12.4;
  o teste de contrato roda contra o 12.4).

## Verificação

1. Reconstruir o dev container; `curl $JELLYFIN_TEST_URL/System/Info/Public` responde.
2. `cd lighthouse && tool/check.sh` → formato, análise, unitários/widget, `--tags server`, `integration_test` sob Xvfb, tudo verde.
3. Manual: `flutter run -d linux` contra o servidor de dev (`$JELLYFIN_URL`), logar, tocar o Test Movie com som e
   legenda, sair no meio e conferir "Continuar assistindo".
