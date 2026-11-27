// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Lighthouse';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageHelp =>
      'Dos textos do app. Títulos e sinopses vêm do servidor, no idioma dele.';

  @override
  String failureUnreachable(String url) {
    return 'Não foi possível acessar $url. Confira o endereço e se o servidor está ligado.';
  }

  @override
  String failureNotJellyfin(String url) {
    return '$url não parece ser um servidor Jellyfin.';
  }

  @override
  String failureDifferentServer(String url) {
    return '$url leva a outro servidor Jellyfin, diferente do primeiro endereço.';
  }

  @override
  String failureNotSetUp(String url) {
    return 'O servidor em $url ainda não foi configurado. Abra-o no navegador e conclua o assistente de configuração.';
  }

  @override
  String get failureUnauthorized => 'Usuário ou senha incorretos.';

  @override
  String get failureServerBadCertificate =>
      'O certificado de segurança do servidor não é válido.';

  @override
  String get failureServerUnexpected => 'Resposta inesperada do servidor.';

  @override
  String failureServerStatus(int status) {
    return 'O servidor respondeu com o erro $status.';
  }

  @override
  String get failureStorageKeyring =>
      'Não foi possível guardar o login no chaveiro do sistema.';

  @override
  String get failureStorageDisk => 'Não foi possível salvar no disco.';

  @override
  String failureNotPlayable(String reason) {
    return 'Este item não pode ser reproduzido ($reason).';
  }

  @override
  String get failurePlayer =>
      'A reprodução falhou: não foi possível abrir o vídeo.';

  @override
  String get failureNotReadable =>
      'O formato deste livro ainda não é suportado.';

  @override
  String get errorUnknown => 'Algo deu errado.';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get back => 'Voltar';

  @override
  String get more => 'Mais';

  @override
  String runtimeHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}min';
  }

  @override
  String runtimeHours(int hours) {
    return '${hours}h';
  }

  @override
  String runtimeMinutes(int minutes) {
    return '${minutes}min';
  }

  @override
  String runtimeSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String episodeNumber(int season, int episode) {
    return 'T$season:E$episode';
  }

  @override
  String episodeOnly(int episode) {
    return 'E$episode';
  }

  @override
  String get bookRead => 'Lido';

  @override
  String bookPercentRead(int percent) {
    return '$percent% lido';
  }

  @override
  String get signIn => 'Entrar';

  @override
  String serverNameAndUrl(String name, String url) {
    return '$name · $url';
  }

  @override
  String get username => 'Usuário';

  @override
  String get usernameMissing => 'Digite seu usuário.';

  @override
  String get password => 'Senha';

  @override
  String get changeServer => 'Trocar de servidor';

  @override
  String get connectTitle => 'Conectar a um servidor';

  @override
  String get connectSubtitle => 'Digite o endereço do seu servidor Jellyfin.';

  @override
  String get serverAddress => 'Endereço do servidor';

  @override
  String get fallbackAddress => 'Endereço alternativo (opcional)';

  @override
  String get fallbackAddressHint =>
      'Usado quando o primeiro não responde, por exemplo fora de casa.';

  @override
  String get serverAddressMissing => 'Digite o endereço do servidor.';

  @override
  String get connect => 'Conectar';

  @override
  String offlineBanner(String server) {
    return 'Sem conexão com $server. Tentando de novo…';
  }

  @override
  String get theServer => 'o servidor';

  @override
  String get retryNow => 'Tentar agora';

  @override
  String get home => 'Início';

  @override
  String get searchTooltip => 'Buscar (Ctrl+F)';

  @override
  String get searchHintShort => 'Títulos, pessoas, gêneros';

  @override
  String get darkTheme => 'Tema escuro';

  @override
  String get lightTheme => 'Tema claro';

  @override
  String get settings => 'Configurações';

  @override
  String get signOut => 'Sair';

  @override
  String get signedOutNotice => 'Você saiu da sua conta.';

  @override
  String get sessionExpiredNotice => 'Sua sessão terminou. Entre novamente.';

  @override
  String get profile => 'Perfil';

  @override
  String get heroMovie => 'FILME';

  @override
  String get heroSeries => 'SÉRIE';

  @override
  String get play => 'Reproduzir';

  @override
  String playEpisode(String episode) {
    return 'Reproduzir $episode';
  }

  @override
  String get episodes => 'Episódios';

  @override
  String get moreInfo => 'Mais informações';

  @override
  String get next => 'Próximo';

  @override
  String get previous => 'Anterior';

  @override
  String get slide => 'Slide';

  @override
  String get noLibraries =>
      'Ainda não há bibliotecas. Crie uma no servidor ou peça acesso ao administrador.';

  @override
  String get continueWatching => 'Continuar assistindo';

  @override
  String get nextUp => 'A seguir';

  @override
  String get continueReading => 'Continuar lendo';

  @override
  String latestIn(String library) {
    return 'Novidades em $library';
  }

  @override
  String get myMedia => 'Minhas mídias';

  @override
  String get read => 'Ler';

  @override
  String get resume => 'Continuar';

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count temporadas',
      one: '1 temporada',
    );
    return '$_temp0';
  }

  @override
  String get markUnwatched => 'Marcar como não assistido';

  @override
  String get markWatched => 'Marcar como assistido';

  @override
  String get details => 'Detalhes';

  @override
  String get loading => 'Carregando';

  @override
  String get nothingHere => 'Nada por aqui ainda.';

  @override
  String get searchHint => 'Buscar filmes, séries, músicas';

  @override
  String nothingFound(String term) {
    return 'Nada encontrado para \"$term\".';
  }

  @override
  String get movies => 'Filmes';

  @override
  String get shows => 'Séries';

  @override
  String get albums => 'Álbuns';

  @override
  String get songs => 'Músicas';

  @override
  String get books => 'Livros';

  @override
  String resumeFrom(String position) {
    return 'Continuar de $position';
  }

  @override
  String get startOver => 'Do começo';

  @override
  String continueReadingPercent(int percent) {
    return 'Continuar lendo · $percent%';
  }

  @override
  String get markUnread => 'Marcar como não lido';

  @override
  String get markRead => 'Marcar como lido';

  @override
  String get watched => 'Assistido';

  @override
  String get seasons => 'Temporadas';

  @override
  String get tracks => 'Faixas';

  @override
  String get playback => 'Reprodução';

  @override
  String get maxQuality => 'Qualidade máxima';

  @override
  String get maxQualityHelp =>
      'Neste aparelho. Acima dela o servidor converte o vídeo para baixo; diminua numa rede lenta.';

  @override
  String get qualityMaximum => 'Máxima';

  @override
  String get appearance => 'Aparência';

  @override
  String get account => 'Conta';

  @override
  String get audioLanguage => 'Idioma do áudio';

  @override
  String get audioLanguageHelp =>
      'Tocado quando o arquivo tem. Fica salvo na sua conta no servidor.';

  @override
  String get fileDefault => 'O padrão do arquivo';

  @override
  String get subtitleLanguage => 'Idioma da legenda';

  @override
  String get anyLanguage => 'Qualquer um';

  @override
  String get showSubtitles => 'Mostrar legendas';

  @override
  String get subtitlesDefault => 'Quando o arquivo indicar';

  @override
  String get subtitlesSmart => 'Quando o áudio estiver em outro idioma';

  @override
  String get subtitlesAlways => 'Sempre';

  @override
  String get subtitlesForced => 'Só legendas forçadas';

  @override
  String get subtitlesNever => 'Nunca';

  @override
  String get lockControls => 'Bloquear controles';

  @override
  String get holdToUnlock => 'Segure para desbloquear';

  @override
  String get chapters => 'Capítulos';

  @override
  String chapterNumber(int number) {
    return 'Capítulo $number';
  }

  @override
  String seasonNumber(int number) {
    return 'Temporada $number';
  }

  @override
  String get playingNow => 'Reproduzindo';

  @override
  String get close => 'Fechar';

  @override
  String get autoplayNext => 'Reproduzir o próximo episódio automaticamente';

  @override
  String get swipeLevels => 'Deslizar para brilho e volume';

  @override
  String get swipeLevelsHelp =>
      'Para cima ou para baixo no vídeo: a metade esquerda muda o brilho, a direita o volume.';

  @override
  String get swipeSeek => 'Deslizar para avançar e voltar';

  @override
  String get swipeSeekHelp =>
      'Para os lados no vídeo: volta ou avança, mais longe quanto maior o gesto.';

  @override
  String themeNotUsed(String file, String error) {
    return '$file: não usado ($error)';
  }

  @override
  String get theme => 'Tema';

  @override
  String get themeHelp => 'Cores, tipografia e formas, de um design system.';

  @override
  String themeFromFolder(String name) {
    return '$name (sua pasta)';
  }

  @override
  String get mode => 'Modo';

  @override
  String get singleMode => 'Este tema tem um modo só.';

  @override
  String get modeDark => 'Escuro';

  @override
  String get modeLight => 'Claro';

  @override
  String get modeSystem => 'Sistema';

  @override
  String get yourThemes => 'Seus temas';

  @override
  String yourThemesHelp(String folder) {
    return 'Coloque o tokens.json de um design system em $folder: ele aparece aqui na hora, e as mudanças valem assim que você salva.';
  }

  @override
  String get openFolder => 'Abrir pasta';

  @override
  String themeIssues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count problemas de tema',
      one: '1 problema de tema',
    );
    return '$_temp0';
  }

  @override
  String playbackStopped(String position) {
    return 'A reprodução parou em $position: a conexão com o servidor caiu.';
  }

  @override
  String get trackChangeFailed => 'Não foi possível trocar a faixa.';

  @override
  String get subtitlesOff => 'Desligadas';

  @override
  String withShortcut(String label, String shortcut) {
    return '$label ($shortcut)';
  }

  @override
  String get keySpace => 'Espaço';

  @override
  String get back10 => 'Voltar 10 segundos';

  @override
  String get pause => 'Pausar';

  @override
  String get forward10 => 'Avançar 10 segundos';

  @override
  String get subtitles => 'Legendas';

  @override
  String get fullScreen => 'Tela cheia';

  @override
  String get exitFullScreen => 'Sair da tela cheia';

  @override
  String get floatingWindow => 'Janela flutuante';

  @override
  String get backToWindow => 'Voltar à janela';

  @override
  String get mute => 'Silenciar';

  @override
  String get unmute => 'Ativar som';

  @override
  String get transcoding => 'Convertendo';

  @override
  String get seekPosition => 'Posição';

  @override
  String hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String seconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segundos',
      one: '1 segundo',
    );
    return '$_temp0';
  }

  @override
  String positionOf(String position, String length) {
    return '$position de $length';
  }

  @override
  String get speedNormal => 'Normal';

  @override
  String get audio => 'Áudio';

  @override
  String get speed => 'Velocidade';

  @override
  String endsAt(String time) {
    return 'Termina às $time';
  }

  @override
  String get watchNow => 'Assistir agora';

  @override
  String get hide => 'Ocultar';

  @override
  String upNextIn(int seconds) {
    return 'A SEGUIR · EM $seconds S';
  }

  @override
  String trackNumber(int number) {
    return 'Faixa $number';
  }

  @override
  String backToPage(int page) {
    return 'Voltar à página $page';
  }

  @override
  String get contentsAndBookmarks => 'Sumário e marcadores';

  @override
  String get removeBookmark => 'Remover marcador';

  @override
  String get bookmarkPage => 'Marcar esta página';

  @override
  String get display => 'Exibição';

  @override
  String pageOf(int page, int count) {
    return 'Página $page de $count';
  }

  @override
  String pagesOf(int first, int last, int count) {
    return 'Páginas $first–$last de $count';
  }

  @override
  String get contents => 'Sumário';

  @override
  String get bookmarks => 'Marcadores';

  @override
  String get noContents => 'Este livro não tem sumário.';

  @override
  String get noBookmarks =>
      'Ainda não há marcadores. O botão de marcador no alto marca a página em que você está.';

  @override
  String page(int page) {
    return 'Página $page';
  }

  @override
  String get smallerText => 'Texto menor';

  @override
  String percent(int value) {
    return '$value%';
  }

  @override
  String get largerText => 'Texto maior';

  @override
  String get readerTheme => 'Tema';

  @override
  String get readerFont => 'Fonte';

  @override
  String get fontSizeLabel => 'Tamanho da fonte';

  @override
  String get lineHeight => 'Altura da linha';

  @override
  String get lessLineHeight => 'Menos espaço entre as linhas';

  @override
  String get moreLineHeight => 'Mais espaço entre as linhas';

  @override
  String get letterSpacing => 'Espaçamento entre caracteres';

  @override
  String get lessLetterSpacing => 'Menos espaço entre as letras';

  @override
  String get moreLetterSpacing => 'Mais espaço entre as letras';

  @override
  String get justify => 'Justificar';

  @override
  String get alignLeft => 'Alinhar à esquerda';

  @override
  String get alignJustified => 'Justificado';

  @override
  String get pageLayout => 'Layout da página';

  @override
  String get layoutAuto => 'Automático';

  @override
  String get layoutSingle => 'Uma página';

  @override
  String get layoutDouble => 'Duas páginas';

  @override
  String get readerLight => 'Claro';

  @override
  String get readerSepia => 'Sépia';

  @override
  String get readerDark => 'Escuro';

  @override
  String trackTitled(String language, String title) {
    return '$language · $title';
  }

  @override
  String get trackForced => 'Forçada';

  @override
  String get libraries => 'Bibliotecas';

  @override
  String get navSearch => 'Buscar';

  @override
  String get mediaNotificationChannel => 'Reprodução';

  @override
  String get notes => 'Anotações';

  @override
  String get noNotes =>
      'Nenhum destaque ainda. Selecione um trecho numa página (arraste sobre ele, ou toque e segure numa tela de toque) para destacá-lo ou fazer uma anotação.';

  @override
  String get addNote => 'Adicionar observação';

  @override
  String get editNote => 'Editar observação';

  @override
  String get copyText => 'Copiar';

  @override
  String get textCopied => 'Texto copiado';

  @override
  String get removeHighlight => 'Remover destaque';

  @override
  String get highlightYellow => 'Amarelo';

  @override
  String get highlightRed => 'Vermelho';

  @override
  String get highlightBlue => 'Azul';

  @override
  String get note => 'Observação';

  @override
  String get noteHint => 'Escreva o que achou deste trecho';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get recordVoice => 'Gravar áudio';

  @override
  String voiceNote(String length) {
    return 'Nota de voz · $length';
  }

  @override
  String get playVoice => 'Ouvir nota de voz';

  @override
  String get stopVoice => 'Parar nota de voz';

  @override
  String get deleteVoice => 'Apagar nota de voz';

  @override
  String get recording => 'Gravando…';

  @override
  String get recordingFailed =>
      'Não foi possível gravar. Verifique se há um microfone conectado e se o app tem permissão para usá-lo.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');
}
