# Plano: Jellyfin Desktop em Flutter (`/workspace/jellyfin-flutter`)

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
- Código em `/workspace/jellyfin-flutter`, **versionado pelo repo git da raiz** (não é ignorado no `.gitignore`).
- `jellyfin/` e `jellyfin-desktop/` ficam só como referência.

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
| Testes | `flutter_test`, `integration_test`, `mocktail` | |
| Lint | `flutter_lints` + regras estritas no `analysis_options.yaml` | |

Cliente da API **escrito à mão** (só os endpoints usados), não gerado do OpenAPI: o gerador precisa de Java e gera
milhares de arquivos. Para não perder a garantia de contrato, um **teste de contrato** (abaixo) compara cada endpoint e
campo usado contra o `/api-docs/openapi.json` do servidor de teste (já confirmado que responde 200).

## Estrutura

```
jellyfin-flutter/
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

### Servidor de teste isolado

- Novo serviço `jellyfin-test` no `docker-compose.yml` (mesma imagem `jellyfin/jellyfin:12.4`), `/config` em **tmpfs**
  (zera a cada `up`), sem porta publicada, mídia de `../jellyfin-flutter/fixtures/media`. Env no app:
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
- `postCreate.sh`: caminho do projeto `jellyfin-desktop/flutter` → `jellyfin-flutter`.
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
2. `cd jellyfin-flutter && tool/check.sh` → formato, análise, unitários/widget, `--tags server`, `integration_test` sob Xvfb, tudo verde.
3. Manual: `flutter run -d linux` contra o servidor de dev (`$JELLYFIN_URL`), logar, tocar o Test Movie com som e
   legenda, sair no meio e conferir "Continuar assistindo".
