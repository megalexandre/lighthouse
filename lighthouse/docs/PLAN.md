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
    abas, carrossel, busca, menu de perfil, setas das fileiras), `phone_navigation` (barra embaixo, rail, folha do
    perfil, voltar do sistema) e `touch` (toque longo no card, carrossel deslizado). Uma pasta só, porque navegam
    pelas mesmas telas e dividem os passos.
  - `player/`: `playing` (play, retomar, pausa, setas, OSD, fim, erro), `playing_on` (próximo episódio, Next e
    Previous, álbum, tela cheia e volume entre episódios, autoplay desligado), `controls` (menus e teclas de áudio e
    legenda, volume, tela cheia, transcode), `on_screen_controls` (capítulos, ±10 s, velocidade, Esc), `up_next`,
    `keyboard_tracks`, `connection_lost` (playback interrompido, reporte enviado na volta do servidor) e `touch` (toque,
    duplo toque, prévia da barra, voltar do sistema).
  - `reader/`: `reading` (quadrinho: virar página, salvar o lugar, lido, biblioteca e home), `epub` (diagramação,
    sumário, marcadores, temas, fonte, links), `reading_offline` e `phone` (voltar do sistema).
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
- Endereço alternativo: a tela Conectar aceita um segundo endereço (opcional) do mesmo servidor, por exemplo
  `fedora.local` e um domínio que funciona de fora. `ServerInfo.addresses` guarda os dois como digitados, o
  preferido primeiro; `url` é o que está em uso. Ao conectar, todos são testados ao mesmo tempo, e um que leve a
  outro servidor (outro Id) é recusado. Um que não responde é aceito sem checagem, porque de casa o domínio
  externo muitas vezes não responde (sem hairpin NAT). Ao abrir o app e quando a conexão cai, `locateServer`
  testa todos e fica com o primeiro, na ordem, que responder com o mesmo Id: em casa volta para o local. O
  token vale em qualquer endereço, porque é o mesmo servidor.

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
- **Página dupla (feita):** duas páginas lado a lado, como um livro aberto, para todos os formatos. A capa fica
  sozinha à direita, então as páginas ímpares ficam sempre à esquerda (`presentation/spreads.dart`, Dart puro e
  testado). A página da direita é a folha que vira, presa na lombada, e assenta sobre a da esquerda como num livro:
  o verso dela é a próxima página da esquerda, e por baixo aparece a próxima da direita; arrastar na página da
  esquerda traz a anterior de volta por cima. O `PageCurlView` cobre a abertura inteira, e o shader desenha a folha
  na metade direita (`uSpine`) com mais duas imagens: o verso (`uBack`) e a página da esquerda por baixo
  (`uUnderLeft`; ao lado da capa, a mesa). A geometria continua em coordenadas da folha; numa página só o desenho
  é o mesmo de antes (os goldens não mudaram). Soltar antes da lombada volta; depois dela (ou com flick) vira.
  Goldens `spread_*`. O EPUB é
  diagramado para a metade da largura. Layout nas opções de exibição: **Automático** (o padrão: duas páginas quando
  a janela é mais larga que alta e cada página fica com pelo menos 420 px), **Uma página** ou **Duas páginas**.
  Chegar à última abertura marca o livro como lido. Cenários em `test/scenarios/reader/layout.feature`; os outros
  cenários do leitor e os de integração fixam uma página, porque as janelas de teste são largas.
- **L3 (feita):** sumário, links internos, fonte, temas e marcadores.
  - Sumário: no EPUB vem do nav (EPUB 3) ou do NCX (EPUB 2); sem nenhum dos dois, são os capítulos que começam
    com título. No PDF vem do outline do PDFium; quadrinhos não têm. Os itens e os marcadores são frações do livro
    (`EpubBook.offsetOf`: caracteres até a âncora), então continuam certos depois de repaginar.
  - Links internos (EPUB): tocar no link vai até a âncora, e um botão "Back to page N" volta. Links externos são
    ignorados.
  - Opções de exibição (EPUB), no painel "Exibição", cada uma numa seção como no Play Livros: fonte (Noto Sans, o
    padrão e a livre mais parecida com a Amazon Ember; Literata; Atkinson Hyperlegible; todas OFL, embutidas, ver
    `assets/fonts/README.md`), tamanho (80 a 175%), altura da linha (80 a 150%), espaçamento entre caracteres (0 a 5
    passos de 0,025 em) e justificar ou alinhar à esquerda. Mudar repagina e mantém o trecho. Preferências antigas
    em px viram o degrau mais próximo; a escolha antiga serifa/sem serifa (fontes genéricas do sistema) é descartada.
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

**A — Android (A1 e A2a feitas; A2b e A2c com o código feito, falta o aparelho; A2d planejada)**
Primeiro o layout de celular (A1), só depois a infraestrutura (A2). Por enquanto o celular só tem o tema **Prime**
(o padrão): o Lanterna continua como está no desktop, sem layout de celular, e os testes de celular usam o Prime.
Toda a A1 roda e se testa no Linux: as telas
dependem do tamanho da janela e do tipo de entrada, não do sistema operacional. Por isso não precisa de SDK do
Android, nem de emulador ou build de APK.

Ponto de partida: `WindowSize` (`lib/core/window_size.dart`, classes de largura do Material 3, mais `isShort`) já
existe e é usado em parte (barra do Prime, carrossel, cabeçalho do item, OSD, linhas de Configurações). Capturas a
360×800 e a 800×360 (Prime e Lanterna) mostraram o seguinte:
- Barra do Prime: as abas das bibliotecas não cabem e aparecem cortadas ("Sh") entre a busca e o perfil.
- Detalhes do item: o pôster ocupa a largura toda e enche a primeira tela, então o título e o Play ficam abaixo da
  dobra.
- Biblioteca: grade de 2 colunas com cards de largura fixa e muito espaço vazio. Deitado (800 de largura) também
  ficam só 2 colunas.
- Home deitada (360 de altura): o carrossel toma a tela inteira.
- Linhas da home: cards de 240 px e o espaço reservado para o hover (`ItemCard.hoverRoom`) desperdiçam espaço no
  celular.
- Mouse e teclado presumidos: o painel do card abre no hover, o card sobe no hover, um toque no vídeo pausa, o
  duplo toque alterna tela cheia, o volume aparece na OSD e o Esc volta.

Dois eixos, decididos em lugares diferentes:
- **Tamanho** (`WindowSize`): quantas colunas, onde fica a navegação, quanto a capa ocupa. Vale também no desktop
  com a janela estreita.
- **Entrada** (toque ou mouse): hover, gestos, alvos de toque, atalhos. Vem de `Theme.of(context).platform`
  (Android/iOS = toque). Os testes trocam com `debugDefaultTargetPlatformOverride` ou a variante
  `TargetPlatformVariant`, sem provider novo.

- **A1a, fundação e testes (feita):**
  - Testes: `usePhone` / `TestApp.openOnPhone` (`test/support/fakes.dart`) abrem o app como num Android: janela de
    celular (em pé ou deitado), barra de status, barra de gestos e o recorte da câmera (`PhoneInsets`), plataforma
    Android e escala de fonte. O `flutter test` usa Android por padrão; por isso o `TestApp` passou a rodar como
    Linux, e só o `usePhone` escolhe Android.
  - Toque ou mouse: `isTouch(context)` (`lib/core/touch.dart`) segue a plataforma (`Theme.of(context).platform`).
    Botões do Material já ganham alvo de 48 px no Android (`materialTapTargetSize.padded`).
  - `test/features/phone/phone_layout_test.dart` passa em todas as telas, em pé e deitado:
    - nenhum texto ou ícone fica sob a barra de status, o recorte ou a barra de gestos (o que rola pode passar sob a
      barra de gestos);
    - os alvos de toque seguem a diretriz do Android (`androidTapTargetGuideline`);
    - nada transborda com fonte 1,3×.
  - Áreas seguras:
    - Biblioteca, item, busca, Configurações e login ficam fora do recorte lateral e rolam por baixo da barra de
      gestos.
    - Na home do Prime, o carrossel vai de ponta a ponta, mas a legenda e as linhas começam depois do recorte.
    - A barra flutuante soma a barra de status à sua altura (`FloatingTopBar.extentOf`): antes ela espremia o
      conteúdo em 40 px.
  - Fonte grande: a legenda dos cards mede a altura com a fonte do usuário (`ItemCard.textHeightOf`), com 48 px de
    mínimo, então o desktop não muda.
  - Alvos de toque no modo toque:
    - A barra de progresso do player tem 48 px de altura para pegar, com a mesma aparência.
    - A marca, a busca e o perfil da barra do topo têm 48 px.
    - O carrossel se desliza; os pontos viram só indicadores e o leitor de tela o rola como lista.
  - No celular, o campo de busca inline não cabia e transbordava; a A1b tirou a busca da barra do topo abaixo do
    desktop.
  - Voltar do sistema (cenários `browse/phone_navigation`, `player/touch`, `reader/phone`) faz o que o Esc faz:
    - no player, sobe um nível no menu, fecha o menu e só então sai, salvando o ponto de retomada;
    - no leitor, fecha o sumário antes de sair;
    - com o campo de busca da barra do topo aberto (tablet deitado), fecha o campo antes de sair da home.
    - Antes, o `PopScope(canPop: false)` da tela passava na frente da gaveta e do menu e fechava a tela inteira.
  - Pendente para a A1d: no toque, a prévia da barra de progresso continua na tela depois de soltar o dedo (no mouse
    ela some quando o ponteiro sai).
- **A1b, navegação (feita):** `BrowseFrame` (`home/presentation/browse_navigation.dart`) envolve a home e as
  páginas de biblioteca do Prime.
  - Celular (compact): `NavigationBar` embaixo com Início, Bibliotecas, Buscar e Perfil.
  - Tablet e celular deitado (medium): `NavigationRail` à esquerda, com os mesmos destinos. O trilho fica fora do
    recorte da câmera.
  - Desktop (expanded ou mais): nada muda, as abas continuam na barra do topo.
  - Abaixo do desktop, a barra do topo mostra só a marca e o título da página (o nome da biblioteca, ou
    "Bibliotecas"); as abas, a busca e o perfil saíram dela.
  - Bibliotecas: página nova (`/libraries`, `LibrariesScreen`) com as bibliotecas em grade. Abrir uma deixa
    Bibliotecas marcado na navegação.
  - Buscar abre a página de busca. Perfil abre uma folha (`ProfileSheet`) com quem está conectado, o modo do tema,
    Configurações e Sair, os mesmos itens (e chaves) do menu do desktop.
  - Cenários em `test/scenarios/browse/phone_navigation.feature`.
- **A1c, telas de navegação (feita):** testes em `test/features/phone/browse_layout_test.dart`; o toque longo e o
  carrossel em `test/scenarios/browse/touch.feature`.
  - Margens: `WindowSize.margin` (16 px no celular, 24 acima, como no Material 3).
  - Home:
    - No celular, os cards das linhas têm 75% da largura (cerca de 3 pôsteres à vista).
    - No toque, as linhas não reservam a folga do hover (`ItemCard.hoverRoom`).
    - Em janela baixa (celular deitado), o carrossel tem 80% da altura e a legenda fica enxuta (título numa linha,
      sem sinopse), então a primeira linha aparece embaixo.
  - Biblioteca: no celular, cards de até 120 px, o que dá 3 colunas.
  - Item: no celular e em janela baixa, o pôster fica pequeno ao lado do nome e dos dados, e os selos e a sinopse vão
    para baixo, de largura total. O Play fica na primeira tela, em pé e deitado.
  - Busca: as linhas por tipo continuam (rolagem horizontal, comum no celular), com os cards menores das linhas.
  - Configurações: o "Abrir pasta" já só aparecia no Linux. Linhas sem texto de ajuda não ficam mais centralizadas no
    celular.
  - Cards no toque: o toque longo abre `CardActions`, uma folha com a ação principal, "marcar como visto" e
    Detalhes, com as regras do painel do hover (`cardMainAction`, `setWatched`). Com o mouse, nada muda.
- **A1d, player e leitor no toque (feita):** cenários em `test/scenarios/player/touch.feature`.
  - Player no toque (vídeo):
    - Um toque mostra ou esconde os controles e não pausa. O play/pausa é o botão da fileira de transporte, e o botão
      central aparece com o vídeo pausado.
    - Duplo toque na metade esquerda volta 10 s; na direita, avança 10 s.
    - Sem botão de volume, que fica com as teclas do aparelho.
    - A prévia da barra de progresso some ao soltar o dedo.
    - A legenda e o card "A seguir" sobem o que os controles cresceram: 32 px da barra de progresso no toque, e a
      segunda fileira no celular. O card não considerava essa fileira.
    - Com o mouse e na música, nada muda (um toque pausa; duplo toque, tela cheia).
  - O botão de tela cheia continua; no Android ele vira modo imersivo na A2.
  - Leitor: já era guiado pelo toque. As barras de cima e de baixo respeitam as áreas seguras e os alvos de toque
    (`phone_layout_test`). O modo de duas páginas na paisagem continua com a L.
- **Pronto (A1 feita):**
  - No celular em pé e deitado e em modo toque:
    - `test/features/phone/` (widget tests) cobre o layout, que é medida: áreas seguras, alvos de toque, fonte
      grande e o que cabe na primeira tela;
    - os cenários cobrem o comportamento: a navegação e o voltar do sistema, o toque longo, o carrossel e o player.
      `Given the app runs on a {'phone'}` (`TestApp.runOn`, `TestDevice`) faz o `When` seguinte abrir o app no
      celular, em Prime.
  - Nada mudou no desktop: os cenários e os testes de integração seguem verdes. A única mudança neles é o passo
    `i_press`, que envia as teclas como Android.

**A2, infraestrutura (planejada):** o app de verdade no Android. Quatro etapas, como na A1; cada uma termina num
aparelho, não só nos testes.

Decisões:
- Distribuição: APK assinado no GitHub Releases, ao lado do AppImage. Sem Play Store por enquanto: nada de AAB,
  conta de desenvolvedor ou declaração de serviço em primeiro plano.
- `applicationId`: `io.github.megalexandre.lighthouse`. Não muda depois da primeira instalação publicada.
- minSdk 24 (o padrão do Flutter 3.50). ABIs: arm64-v8a para os aparelhos e x86_64 para o emulador. Um APK por ABI,
  porque o libmpv pesa dezenas de MB em cada uma.
- Teste à mão: emulador no dev container (`tool/emulator.sh`), com o `/dev/kvm` do host. Onde não há KVM, emulador no
  host (Android Studio):
  - O adb do container fala com o servidor adb do host: `adb -a nodaemon server start` no host e
    `ADB_SERVER_SOCKET=tcp:host.docker.internal:5037` no container.
  - O emulador do host alcança o servidor de dev em `http://10.0.2.2:8096`, que é a porta publicada no host.
- Áudio em segundo plano entra na A2 (A2c): sem ele, a música para quando a tela apaga.

Achados no código, que no Android quebram sem erro visível:
- `ClientInfo.device` usa `Platform.localHostname`, que no Android é `localhost`. Esse é o nome na lista de
  dispositivos do servidor; tem que vir do modelo do aparelho.
- `defaultLogDirectory` lê `XDG_DATA_HOME`/`HOME`, que não existem no Android, e o app abriria sem arquivo de log.
- `NativeAppWindow` usa o `window_manager` 0.7, que é FFI sem implementação Android.
- O Android 9+ bloqueia HTTP sem TLS, e o `dart:io` (dio) respeita esse bloqueio: um servidor `http://` na rede
  local não conectaria.
- O backup automático do Android restauraria o `device_id` em outro aparelho, e dois aparelhos com o mesmo
  DeviceId fazem o Jellyfin revogar tokens.
- O mpv roda com `tls-verify=yes`, e no Android o ffmpeg pode não achar as CAs do sistema: o vídeo por HTTPS
  falharia com a API funcionando.
- "Abrir pasta" dos temas (`xdg-open`) já é só do Linux, mas no Android a pasta é privada do app.

- **A2a, o app abre no Android (feita):** conferido num celular com o APK de release arm64: entra no servidor de
  dev por `http://`, reabrir o app mantém a sessão, abre PDF, CBZ e EPUB (com a virada de página), e um vídeo toca
  com troca de áudio e legenda (media_kit, `media_kit_libs_android_video` 1.3.8).
  - O que saiu:
    - `android/` com `applicationId` `io.github.megalexandre.lighthouse`; no manifest, `INTERNET` (o template só
      pedia no debug e no profile, e o release não falaria com o servidor), HTTP sem TLS, o domínio `sharedpref`
      inteiro fora do backup e da transferência entre aparelhos (só o `flutter_secure_storage` mora lá), o nome
      "Lighthouse" e o ícone do Linux.
    - `ImmersiveAppWindow` (`core/window.dart`); `appLogDirectory()` (`core/log.dart`); o nome do aparelho vem do
      canal `lighthouse/device` (`MainActivity.kt`): o nome dado ao celular nas configurações, senão `Build.MODEL`.
    - O "Abrir pasta" dos temas já era só do Linux; temas, leitor e aparência já usavam o `path_provider`.
  - Achados:
    - O lint do release (`lintVital`) quebra dentro do próprio lint (AGP 9.3.1) ao ler o Javadoc do
      `url_launcher_android`. Desligado só nos plugins (`android/build.gradle.kts`); o do app continua.
    - Um plugin compila contra a platform 35, que o Gradle instalaria no SDK da imagem e se perderia no rebuild:
      está no Dockerfile.
    - O primeiro build leva ~20 min (Gradle ~2,6 GB em `~/.gradle`, volume próprio). O media_kit baixa o libmpv
      do GitHub durante o build.
    - Tamanho: debug x86_64 147 MB; release arm64 75,6 MB, dos quais ~28 MB são as bibliotecas x86_64 e armv7 que
      o media_kit embute mesmo com `--target-platform`. O APK por ABI da A2d resolve.
  - O plano original, para referência:
    - Prova primeiro, antes do resto: `flutter create --platforms=android`, `media_kit_libs_android_video` e um vídeo
      tocando no emulador. Ela mede o media_kit com o Flutter 3.50 e o Impeller, e o tamanho do APK. Se o media_kit
      não funcionar, o resto do plano muda.
    - Android SDK no dev container: cmdline-tools, platform, build-tools e o NDK que o Flutter pedir, fixados no
      Dockerfile como o Flutter.
    - `AndroidManifest`/recursos:
      - `network_security_config` que permite HTTP sem TLS, para servidores na rede local;
      - `dataExtractionRules`/`fullBackupContent` que deixam o armazenamento seguro fora do backup;
      - nome, ícone e `applicationId`.
    - Código:
      - `AppWindow` do Android: tela cheia = modo imersivo (`SystemChrome`); o `window_manager` só no desktop.
      - Log em `getApplicationSupportDirectory()/logs` fora do Linux.
      - Nome do aparelho pelo modelo (`Build.MODEL`).
      - Settings: sem "Abrir pasta" dos temas no Android; importar um tema fica para depois.
    - Conferir no aparelho: `flutter_secure_storage` (Keystore; sessão e DeviceId sobrevivem a reabrir),
      `path_provider`, o `FileKeyValueStore` do leitor, o pdfrx/PDFium e o shader da virada de página.
    - Pronto quando: o APK de debug instala no emulador, entra no servidor de dev por `http://`, navega e abre PDF,
      CBZ e EPUB. Reabrir o app mantém a sessão.
- **Leitor no celular (feito, entre a A2a e a A2b):** pedido depois de usar o APK da A2a.
  - Duas páginas nunca numa tela pequena (`WindowSize.compact` ou baixa, o celular em pé ou deitado), nem com
    "Duas páginas" escolhido: ficariam pequenas demais para ler. A escolha fica salva e volta a valer num tablet ou
    no desktop.
  - Tela cheia no toque: a folha é a tela inteira, de borda a borda, sem mesa em volta (com duas páginas, num tablet,
    continua o livro aberto sobre a mesa). Num EPUB o texto desvia da câmera e das barras do sistema (`keepClear`) e a
    linha tem no máximo 640 px; um PDF ou quadrinho aparece o maior que couber, sem corte, com o papel em volta. As barras do
    leitor vêm por cima dela. O toque no meio esconde as barras do leitor e as do Android juntas (`AppWindow`,
    modo imersivo); sair do livro devolve as barras. As margens das barras do sistema guardam o maior valor visto
    em cada orientação, então esconder as barras não move a página: num EPUB, mover a página repaginaria o livro.
  - No desktop nada mudou: a margem fixa para as barras e a janela como está.
  - Cenários em `test/scenarios/reader/phone.feature`.
- **A2b, reprodução (código feito; falta conferir no aparelho):**
  - O que saiu:
    - Decodificação: `hwdec=mediacodec,mediacodec-copy` no Android (o mpv do APK aceita lista). No emulador continua
      `no`, a escolha do media_kit.
    - HTTPS: o ffmpeg do libmpv do Android usa mbedTLS, que não conhece as CAs do sistema. A `MainActivity` escreve
      as do `AndroidCAStore` num PEM no cache, uma vez por execução, e o mpv o recebe em `tls-ca-file`
      (`core/system_certificates.dart`). Só as do sistema, como o `dart:io`. `tls-verify` segue ligado: sem o arquivo,
      o vídeo por HTTPS não toca, mas o token não vaza.
    - Vídeo no toque: em paisagem e tela cheia até a última tela do player fechar (`AppWindow.isLandscape`,
      `PlayerFullscreenNotifier.enterVideo`); o próximo episódio continua como o usuário deixou. Música não mexe na
      orientação. A tela acesa no vídeo já vinha do media_kit_video; no leitor é `AppWindow.staysOn` (wakelock_plus).
    - DeviceProfile: igual, por enquanto.
  - Conferir no aparelho:
    - um HEVC 1080p com `hwdec-current=mediacodec` (ou `-copy`) no log, com troca de áudio e legenda;
    - o ponto de retomada no servidor;
    - um vídeo por HTTPS com certificado público. O ffmpeg desiste se um só certificado do PEM não puder ser lido
      pelo mbedTLS; se for o caso, filtrar o que falhar;
    - a superfície volta depois de o app ir para segundo plano.
- **A2c, áudio em segundo plano (código feito; falta conferir no aparelho):** cenários em
  `test/scenarios/player/background.feature`.
  - Pacotes: `audio_service` (serviço, notificação, botões) e `audio_session` (foco), em vez de um canal próprio. A
    `MainActivity` estende `AudioServiceActivity`, senão o plugin subiria um segundo motor do Flutter.
  - O que saiu:
    - Troca de faixa no `PlayerController` (`playInstead`), na mesma tela e no mesmo mpv. Antes a tela trocava de
      rota, e com a tela do celular apagada o Flutter não desenha frames: o álbum pararia na primeira faixa. Vale
      também no desktop. Episódios continuam trocando de rota.
    - Música abre sem vídeo (`PlayerEngine.open(video: false)`): a capa embutida ganharia uma superfície, e o
      media_kit faz um seek quando o Android a toma de volta.
    - `MediaControls` (notificação e tela de bloqueio; a interface serve ao MPRIS na F5+) e `AudioFocus`, com
      implementações vazias no Linux; `SystemMedia` liga os dois a uma reprodução.
    - Foco: uma ligação pausa e, no fim, a música volta (o vídeo só se o app estiver na frente); outro app tocando
      ou o fone desconectado pausam de vez; a pausa à mão durante a ligação vale.
    - O serviço fica em primeiro plano também em pausa: do Android 12 em diante não dá para voltar a ele do segundo
      plano, e é o que retomar depois de uma ligação faria.
    - Dispensar a notificação, ou tirar o app dos recentes, pausa e guarda o ponto.
    - Vídeo pausa em segundo plano (o `Video` do media_kit já fazia) e não tem notificação.
  - Conferir no aparelho: um álbum até o fim com a tela apagada, a notificação troca de faixa (com a capa e o ícone
    no build de release), uma ligação pausa e retoma, o fone desconectado pausa, e os reportes chegam ao servidor
    com a tela apagada.
- **A2d, build, testes e release:**
  - `tool/build_apk.sh`: release, um APK por ABI, assinado com uma chave fora do repo (secrets na CI). Smoke test
    do APK no emulador, como o AppImage.
  - CI: um job com emulador x86_64 (os runners Ubuntu têm KVM) e o servidor de teste em `10.0.2.2:8096`.
  - Testes de integração no Android: os que não dependem do Linux. O keyring e os pixels do PDFium ficam no Linux;
    o mpv sem áudio (`ao=null`) vale nos dois. À mão, o servidor de teste precisa de uma porta publicada no host
    (por exemplo 8097), porque o emulador não resolve `jellyfin-test`.
  - O `tool/check.sh` continua só Linux: o build Android vai para a CI e para um `tool/check_android.sh`.
  - Release: APKs e AppImage na mesma tag.

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
