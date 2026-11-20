# Temas

O visual do app vem de um **design system**: o `tokens.json` que o Claude Design exporta, usado sem conversão. Ele
define cores (modo escuro e claro), fontes, escala de texto, espaçamentos, raios e sombras. Trocar o arquivo muda o
visual inteiro; a estrutura das telas continua a mesma.

Temas embutidos (`assets/themes/`):

- **Prime**, `prime.json`: o **padrão** (o que aparece até o usuário escolher outro, ou quando o escolhido some ou não
  pode ser lido). É a "Lanterna — variação streaming" (azul-noite, acento `#1a98ff`, Inter). A variação é uma
  página, não um design system, então os tokens foram tirados das variáveis CSS dela. O que ela muda além das cores
  é forma e comportamento de componente, e um tema por tokens não carrega isso:
  - top bar fixa, transparente sobre o carrossel, que flutua com blur ao rolar, com abas, busca que se abre e menu
    de perfil;
  - carrossel no topo da home;
  - card que expande no hover, com imagem, botões e sinopse;
  - setas nas fileiras;
  - botão primário branco;
  - controles do player no centro.
- **Lanterna** ([design system](https://claude.ai/artifact/32DMqAFN7kh6VuAugFs2zT)), `lanterna.json`: a **base**.
  Está completo, e é dele que qualquer tema (o Prime também) herda os tokens que faltarem. Não pode sair do app.

No código, `ThemeCatalog.defaultId` é o padrão e `ThemeCatalog.baseId` é a base.

## Modificar o tema

### No Lanterna embutido
1. Edite o Lanterna no Claude Design.
2. Peça ao Claude Code "sincroniza o Lanterna": ele lê `project/tokens.json` do artefato e grava em
   `assets/themes/lanterna.json`.
3. Rode `tool/check.sh` e faça o build. O Lanterna embutido precisa estar completo, porque é dele que os outros temas
   herdam o que faltar. Um token ausente nele quebra os testes, e é de propósito.

### Num tema seu, sem recompilar
1. Duplique o Lanterna no Claude Design, ou crie outro design system, e baixe o `tokens.json`.
2. Coloque o arquivo na pasta de temas, com qualquer nome terminado em `.json`. O caminho aparece em
   **Settings → Appearance → Your themes**, que também tem o botão **Open folder**. No Linux é
   `~/.local/share/<app>/themes/`.
3. O tema aparece na hora em **Settings → Theme**, como "Nome (your folder)". Cada vez que o arquivo é salvo, o app
   recarrega.

O tema escolhido e o modo (escuro, claro ou do sistema) ficam salvos neste aparelho.

## O que o arquivo precisa ter

É o formato do Claude Design (`project/tokens.json`):

```json
{"name": "Meu tema",
 "color": {"themes": [{"id": "dark", "name": "Escuro"}, {"id": "light", "name": "Claro"}],
           "tokens": [{"name": "accent", "value": {"dark": "#00a4dc", "light": "#0077a8"}},
                      {"name": "osd-ink", "value": "#ffffff"}]},
 "type": {"families": {"sans": "\"Noto Sans\", system-ui, sans-serif", "mono": "\"Noto Sans Mono\", monospace"},
          "groups": [{"name": "Texto", "family": "sans",
                      "styles": [{"name": "body", "fontSize": "14px", "lineHeight": "20px", "fontWeight": 400}]}]},
 "spacing": {"tokens": [{"name": "space-4", "value": "16px"}]},
 "radius": {"tokens": [{"name": "radius-md", "value": "8px"}]},
 "shadow": {"tokens": [{"name": "shadow-menu", "value": "0 8px 24px rgba(0, 0, 0, 0.50)"}]}}
```

- **Modos.** O id que contém `dark` é usado no modo escuro, e o que contém `light` no claro. Com um modo só, ele vale
  para os dois, e a escolha de modo fica desativada.
- **Cores.**
  - O app aceita `#rgb`, `#rgba`, `#rrggbb`, `#rrggbbaa`, `rgb()`, `rgba()` e aliases `{outro-token}`.
  - Um valor em string vale para todos os modos.
  - Se falta o valor de um modo, vale o do primeiro.
  - Não são aceitos: nomes de cor (`red`), `hsl()`, `var()`.
- **Fontes.**
  - De cada lista, vale o primeiro nome; os seguintes servem de reserva, e os genéricos (`system-ui`,
    `sans-serif`...) são ignorados.
  - Noto Sans e Noto Sans Mono vêm embutidas (`assets/fonts/`).
  - Qualquer outra família é procurada no sistema pelo nome, via fontconfig.
- **Medidas.**
  - Comprimentos em `px`, `rem` (16 px) ou `em`.
  - `lineHeight` aceita px ou um multiplicador.
  - `letterSpacing` aceita `em`.
- **Sombras.** No formato `x y [blur [spread]] cor`, várias separadas por vírgula. `inset` não é aceito.
- **Tokens ausentes ou ilegíveis.**
  - O app usa o valor do Lanterna e lista o problema em **Settings → N theme issues**, e também no log.
  - Um arquivo que não é JSON aparece ali como "not used".

## Componentes que o tema escolhe (`components`)

Além dos tokens, o tema pode escolher a forma de alguns componentes, entre as que o app já tem. Cada uma é
programada uma vez, e qualquer tema pode usar:

```json
"components": { "topBar": "floating", "homeHero": "carousel", "rowArrows": true, "cardHover": "expand" }
```

| Chave | Valores | O que muda |
| --- | --- | --- |
| `topBar` | `standard` (padrão), `floating` | `floating`: uma marca, as bibliotecas como abas, uma busca que se abre num campo e um menu de perfil (tema claro/escuro, Settings, Sign out). É transparente sobre o carrossel e vira uma barra flutuante, com blur, ao rolar. É sempre escura. Na home, a fileira "My media" sai, porque as abas fazem esse papel. Uma biblioteca aberta pela aba mantém a barra, com a aba dela ativa |
| `homeHero` | `none` (padrão), `carousel` | `carousel`: os filmes e séries adicionados por último (até 6), em tela cheia, com a imagem de fundo (ou o pôster), título grande, sinopse, o botão branco e "More info". O botão branco: Play num filme; numa série, "Play T1:E2" (o próximo episódio, de onde parou) quando ela já foi começada, senão "Episodes" (abre a página dela). Troca a cada 8 s, com fade, pausa no hover e tem setas e pontos. Com "reduzir animações", troca sem fade e sem zoom |
| `rowArrows` | `false` (padrão), `true` | Setas nas laterais das fileiras da home, só onde há mais para ver, avançando uma página por clique. Somem em janela estreita (abaixo de 760 px) |
| `cardHover` | `lift` (padrão), `expand` | `expand`: com o mouse parado 450 ms sobre um filme, episódio, série ou livro, abre por cima um painel maior (1,55× o card, entre 380 e 520 px) que cresce a partir do card. Mostra a imagem larga com o progresso, o título, Play/Resume branco, marcar como assistido, detalhes, a classificação, o ano e a duração, e a sinopse (o item completo é buscado ao abrir). Fecha quando o mouse sai ou a página rola, e fica abaixo da top bar. Só com mouse e em janelas de 800 px ou mais; com teclado, o card continua crescendo com o anel |

Uma chave ou um valor desconhecido vira aviso em Settings, e vale o padrão. O Prime liga todas; o Lanterna não tem a
seção, então fica com os padrões.

Os testes das telas usam o layout do Lanterna (`TestApp` e o `launch` da integração abrem nele). O layout do Prime tem
cenários próprios em `test/scenarios/browse/prime.feature` (e o painel do card em `cards.feature`).

## Que token pinta o quê

Os nomes são os do Lanterna. Um tema novo usa os mesmos nomes; os que ele não tiver vêm do Lanterna.

| Token | No app |
| --- | --- |
| `bg-000` | Fundo mais profundo (`surfaceContainerLowest`) |
| `bg-100` | Fundo das telas, AppBar (`surface`) |
| `bg-200` | Cards, campos, diálogos, menus, gaveta, painel inferior (`surfaceContainer`) |
| `bg-300` | Hover, snackbar, tooltip (`surfaceContainerHigh`) |
| `line` | Divisores e bordas (`outline`) |
| `ink` / `ink-muted` | Texto principal / metadados (`onSurface` / `onSurfaceVariant`) |
| `accent` / `accent-ink` | Cor de ação: botão primário, progresso, seleção, foco (`primary` / `onPrimary`) |
| `accent-hover` | `inversePrimary` |
| `accent-2` | Acento secundário (`secondary`, `tertiary`) |
| `danger` | Erros (`error`); `success`, `warning` em `context.tokens` |
| `osd-*` | Sobre o vídeo e sobre a página do leitor: ícones (`osd-ink`), textos secundários (`osd-ink-muted`), degradê dos controles (`osd-scrim`), barras (`osd-surface`), trilho, buffer e progresso do player (`osd-track`, `osd-buffer`, `osd-accent`). Também sobre imagens: o carrossel da home e a top bar flutuante (texto, botões, degradês a partir de `osd-scrim` opaco, a barra sólida em `osd-surface`, o botão branco com tinta `osd-accent-ink`). Iguais nos dois modos: o player e o que fica sobre imagens são sempre escuros. |
| `hero-title` | `headlineLarge`, `display*` |
| `section-title` | `titleLarge`, `headlineMedium/Small`, títulos da AppBar |
| `title` | `titleMedium/Small` |
| `body` | `bodyLarge/Medium`; em 600, `labelLarge` (botões) |
| `caption` | `bodySmall` (em `ink-muted`); em 600, `labelMedium` (selos) |
| `overline` | `labelSmall` |
| `timecode` | Tempo no player (mono) |
| `space-*` | `context.tokens.space(n)` |
| `radius-sm` / `-md` / `-lg` / `-pill` | Pôsteres 2:3 / cards 16:9, botões, campos / diálogos, menus, painéis / selos |
| `shadow-menu`, `shadow-poster` | `context.tokens.shadowMenu`, `shadowPoster` |

Ficam fora dos tokens:
- os temas de página do leitor (claro, sépia, escuro), que são do leitor;
- o fundo preto atrás do vídeo.

## No código

- **Arquivos** (`lib/core/theme/`):
  - `design_tokens.dart` lê o arquivo;
  - `theme_builder.dart` monta o `ThemeData` (mantenha a tabela acima em dia);
  - `app_tokens.dart` é o que o Material não tem;
  - `theme_catalog.dart` reúne os temas embutidos e os da pasta;
  - `appearance.dart` guarda a escolha e entrega o tema.
- **Nas telas.** Use `Theme.of(context).colorScheme` e `textTheme`, ou `context.tokens` para `osd-*`, espaços, raios
  e o `timecode`. Nunca `Color(0x…)` nem `Colors.white`: uma cor fixa não muda com o tema.
- **Componentes.** Os componentes do design system estão implementados e leem tudo dos tokens, então trocar de tema
  troca o visual deles também.

## Componentes do Lanterna no app

| Componente | No app | Onde |
| --- | --- | --- |
| Button | `AppButton` (primary, secondary, ghost) e `AppIconButton` (redondo, 44 px) | `lib/widgets/app_button.dart` |
| Foco | `FocusRing`: anel de 2 px em `accent`, só na navegação por teclado ou controle | `lib/widgets/focus_ring.dart` |
| Badge | `MediaBadge`: selos técnicos (4K, HDR10, 5.1, CC) no detalhe e a qualidade sobre o vídeo | `lib/widgets/media_badge.dart` |
| MediaCard | `ItemCard`: no hover ou foco, escala 1.04, sombra, anel e o disco de reproduzir (que toca na hora); progresso de 4 px; disco de assistido e de não vistos | `lib/features/library/presentation/item_card.dart` |
| VideoPlayer | Barra de cima, barra de baixo, botão central e fade de 200/400 ms; legendas sobem com os controles; duplo clique alterna a tela cheia; até 720 px some o slider de volume | `lib/features/player/presentation/player_screen.dart` |
| ControlButton | 44 px (Reproduzir 52), hover `osd-hover`, ativo `osd-accent`, tooltip com o atalho | `player/presentation/osd/control_button.dart` |
| SeekBar | Buffer, cortes de capítulo, thumb e prévia com a miniatura do trickplay, o tempo e o capítulo | `player/presentation/osd/seek_bar.dart` |
| SettingsMenu | Audio, Subtitles e Speed, cada um num submenu; Esc volta um nível | `player/presentation/osd/settings_menu.dart` |
| UpNext | Nos últimos 10 s de um episódio, se o autoplay estiver ligado: contagem, Watch now e Hide | `player/presentation/osd/up_next.dart` |

Diferenças em relação ao Lanterna:
- Os textos continuam em inglês. O pt-BR vira uma etapa própria, com i18n.
- Ficam de fora o botão Transmitir, o PiP e a Qualidade no menu, que o app ainda não tem.
- As legendas sobem 96 px, e não 48, porque a barra do app é mais alta.

As miniaturas do trickplay são baixadas pelo cliente autenticado, porque o servidor exige login para servi-las e o
token não vai na URL. Elas só aparecem se o servidor tiver gerado trickplay para o vídeo: a tarefa "Generate Trickplay
Images" do Jellyfin, com a opção ligada na biblioteca.
