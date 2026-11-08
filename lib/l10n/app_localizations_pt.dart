// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get syncUpToDate => 'Em dia';

  @override
  String get syncFailed => 'A sincronização falhou';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays atualizados a partir do teu perfil (NIP-65)';

  @override
  String get relayListPublished => 'Relay list publicada';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Servidores de multimédia atualizados a partir do teu perfil';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Descobrir';

  @override
  String get tabCreate => 'Criar';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Perfil';

  @override
  String get signInToUploadMedia => 'Inicia sessão para carregar multimédia.';

  @override
  String get noMediaServer =>
      'Nenhum servidor de multimédia configurado. Adiciona um nas Definições.';

  @override
  String serverNoResponse(Object server) {
    return '$server: sem resposta';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: inacessível ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Carregamento rejeitado — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Nenhum servidor aceitou o ficheiro — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'resposta inválida';

  @override
  String get blossomInvalidFileUrl => 'endereço de ficheiro inválido';

  @override
  String get blossomServerAlteredFile => 'o servidor alterou o ficheiro';

  @override
  String get blossomBadRequest => 'pedido inválido';

  @override
  String get blossomUnauthorized => 'autorização recusada';

  @override
  String get blossomPaymentRequired => 'pagamento necessário';

  @override
  String get blossomForbidden => 'não permitido';

  @override
  String get blossomLengthRequired => 'tamanho em falta';

  @override
  String get blossomTooLarge => 'ficheiro demasiado grande';

  @override
  String get blossomUnsupportedType => 'formato não aceite';

  @override
  String get blossomTooManyRequests => 'demasiados pedidos';

  @override
  String get blossomServerError => 'erro do servidor';

  @override
  String get cipherInvalidKey => 'Chave inválida';

  @override
  String get cipherTruncated => 'O ficheiro cifrado está truncado';

  @override
  String get cipherMismatch =>
      'O ficheiro não corresponde à chave: modificado ou corrompido';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Formato HEIC/AVIF: a conversão requer sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'O vídeo WebM/MKV não é suportado: usa MP4 ou MOV para os metadados poderem ser removidos antes do carregamento.';

  @override
  String get sanitizeUnknownFormat =>
      'Formato de ficheiro não reconhecido: fotos JPEG/PNG/WebP/GIF ou vídeos MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Não foi possível remover todos os metadados ($items): ficheiro não carregado.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Não foi possível processar o ficheiro: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'JPEG inválido';

  @override
  String get sanitizeJpegTruncated => 'JPEG truncado';

  @override
  String get sanitizeJpegNoSize => 'JPEG sem dimensões';

  @override
  String get sanitizeJpegUndecodable => 'O JPEG não pode ser descodificado';

  @override
  String get sanitizePngTruncated => 'PNG truncado';

  @override
  String get sanitizePngInvalid => 'PNG inválido';

  @override
  String get sanitizeGifInvalid => 'GIF inválido';

  @override
  String get sanitizeGifTruncated => 'GIF truncado';

  @override
  String get sanitizeWebpTruncated => 'WebP truncado';

  @override
  String get sanitizeWebpInvalid => 'WebP inválido';

  @override
  String get sanitizeMp4Invalid => 'Vídeo MP4/MOV inválido';

  @override
  String get sanitizeConversionFailed => 'A conversão falhou';

  @override
  String get sanitizeHeifUnsupported =>
      'Este formato (HEIC/AVIF) não pode ser convertido neste dispositivo. Escolhe uma foto JPEG ou PNG.';

  @override
  String get privateMediaNotEncrypted => 'A multimédia não está cifrada';

  @override
  String serverReplied(Object status) {
    return 'O servidor respondeu $status';
  }

  @override
  String get fileTooLarge => 'Ficheiro demasiado grande';

  @override
  String get serverFileNotOriginal => 'O ficheiro no servidor não é o original';

  @override
  String get contentMismatch => 'O conteúdo não corresponde';

  @override
  String get mediaUnreachable => 'Multimédia inacessível';

  @override
  String get amberInvalidKey => 'Amber devolveu uma chave inválida';

  @override
  String get amberNoKey => 'Amber não devolveu uma chave';

  @override
  String get amberRequestRejected => 'Pedido rejeitado no Amber';

  @override
  String get amberAndroidOnly => 'Amber só está disponível no Android';

  @override
  String get amberEmptySignature => 'Amber devolveu uma assinatura vazia';

  @override
  String get amberSignRejected => 'Assinatura rejeitada no Amber';

  @override
  String get amberTimeout => 'Amber não respondeu a tempo';

  @override
  String get amberEmptyResponse => 'Amber devolveu uma resposta vazia';

  @override
  String get bunkerInvalidUrl => 'URL de bunker inválido';

  @override
  String get bunkerNoRelay => 'O bunker não indica nenhum relay';

  @override
  String get bunkerWebAuth =>
      'O bunker requer autorização web (auth_url não é suportado)';

  @override
  String get bunkerInvalidKey => 'O bunker não devolveu uma chave válida';

  @override
  String get signerInvalidResponse =>
      'O assinador devolveu um evento assinado inválido';

  @override
  String get bunkerTimeout => 'Bunker excedeu o tempo';

  @override
  String get nwcInvalidUri => 'URI NWC inválido';

  @override
  String get nwcNoRelay => 'O URI NWC não indica nenhum relay';

  @override
  String get nwcNoSecret => 'O URI NWC não contém um segredo válido';

  @override
  String get nwcTimeout => 'A carteira excedeu o tempo';

  @override
  String get signerNoPrivateMessages =>
      'Este início de sessão não suporta mensagens privadas';

  @override
  String get zapNotSupported => 'Este endereço não suporta zaps de Nostr';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Montante fora do intervalo ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Comentário não enviado. Tenta mais tarde.';

  @override
  String get comments => 'Comentários';

  @override
  String get noCommentsYet => 'Ainda sem comentários.';

  @override
  String get signInToComment => 'Inicia sessão para comentar.';

  @override
  String get addComment => 'Adiciona um comentário…';

  @override
  String get signInToPublish => 'Inicia sessão para publicar.';

  @override
  String get addMediaFirst =>
      'Adiciona pelo menos uma foto ou um vídeo antes de publicar.';

  @override
  String get removingMetadata => 'A remover metadados…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'A carregar $current de $total…';
  }

  @override
  String get creatingPreview => 'A criar a pré-visualização…';

  @override
  String uploadFailed(Object error) {
    return 'Falha ao carregar: $error';
  }

  @override
  String get publishing => 'A publicar…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Nenhum relay aceitou a publicação$reason. O conteúdo fica nos teus rascunhos.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Este início de sessão não suporta conteúdo privado. Usa Amber, um bunker ou a chave local.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'A tua lista de amigos próximos está vazia: adiciona alguém.';

  @override
  String get fileOver100Mb =>
      'O ficheiro passa dos 100 MB: é o limite para amigos próximos (é cifrado por inteiro no teu telemóvel).';

  @override
  String get encryptingOnPhone => 'A cifrar no teu telemóvel…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Nenhum dos teus servidores de multimédia aceitou o ficheiro cifrado. Não é publicado em claro. Adiciona nas Definições um servidor que aceite ficheiros cifrados (por exemplo cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'A enviar aos amigos…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'A enviar aos amigos $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Nenhum amigo recebeu a publicação$reason. O conteúdo fica nos teus rascunhos.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviado a $count amigos próximos 🔒',
      one: 'Enviado a 1 amigo próximo 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Enviado a $delivered amigos.',
      one: 'Enviado a 1 amigo.',
    );
    return '$_temp0 $missed não receberam (as mensagens privadas estão desligadas).';
  }

  @override
  String get altText => 'Texto alternativo';

  @override
  String get altTextHint => 'Descreve o conteúdo para quem não o consegue ver…';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get momentPublished => 'Momento publicado ✨';

  @override
  String get newMoment => 'Novo momento';

  @override
  String get publish => 'Publicar';

  @override
  String get guestMode => 'Modo convidado';

  @override
  String get signInToPostMoments =>
      'Inicia sessão para publicar os teus momentos.';

  @override
  String get signIn => 'Iniciar sessão';

  @override
  String get kindPhoto => 'Foto';

  @override
  String get kindVideo => 'Vídeo';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'História';

  @override
  String get storyExpiryNote =>
      'As histórias expiram ao fim de 24 horas nos relays que respeitam o NIP-40, mas outros podem guardá-las ou arquivá-las.';

  @override
  String get fromGallery => 'Da galeria';

  @override
  String get galleryLongPressVideo => 'Galeria (toque longo para vídeo)';

  @override
  String get addVideo => 'Adicionar vídeo';

  @override
  String get camera => 'Câmara';

  @override
  String get exifRemovedNote =>
      'Os metadados de localização (EXIF) são removidos automaticamente.';

  @override
  String get writeCaption => 'Escreve uma legenda…';

  @override
  String get privatePostNote =>
      'Publicação privada: sem hashtags públicas, não se encontra na pesquisa.';

  @override
  String willPublishAs(Object caption) {
    return 'Será publicado como: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Toca numa miniatura para adicionar texto alternativo.';

  @override
  String get sensitiveContent => 'Conteúdo sensível';

  @override
  String get sensitiveContentNote =>
      'A publicação fica oculta atrás de um aviso (NIP-36).';

  @override
  String get uploadingMedia => 'A carregar multimédia…';

  @override
  String get audiencePublic => 'Público';

  @override
  String get closeFriends => 'Amigos próximos';

  @override
  String get signerCannotPublishCloseFriends =>
      'Com este início de sessão não podes publicar para amigos próximos: usa Amber, um bunker ou a chave local.';

  @override
  String get closeFriendsEmptyPrompt =>
      'A tua lista está vazia: adiciona quem pode ver esta publicação.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Só os teus $count amigos próximos verão isto. As fotos e os vídeos são cifrados no teu telemóvel antes de serem carregados.',
      one: 'Só o teu 1 amigo próximo verá isto. As fotos e os vídeos são cifrados no teu telemóvel antes de serem carregados.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Adicionar amigos';

  @override
  String get manageList => 'Gerir a lista';

  @override
  String get edit => 'Editar';

  @override
  String get reset => 'Repor';

  @override
  String get apply => 'Aplicar';

  @override
  String get cropFree => 'Livre';

  @override
  String get cropOriginal => 'Original';

  @override
  String get rotate => 'Rodar';

  @override
  String get flip => 'Inverter';

  @override
  String get brightness => 'Brilho';

  @override
  String get contrast => 'Contraste';

  @override
  String get saturation => 'Saturação';

  @override
  String postsByAuthor(Object author) {
    return 'Publicações de $author…';
  }

  @override
  String get searchHint => 'Procura pessoas, hashtags ou palavras…';

  @override
  String get clear => 'Limpar';

  @override
  String get recent => 'Recentes';

  @override
  String get searchDependsOnRelays =>
      'A pesquisa depende dos relays configurados: os resultados podem ser parciais.';

  @override
  String get recentPostsEverywhere =>
      'Publicações recentes de toda a rede, incluindo pessoas que não segues.';

  @override
  String get noResultsOnRelays => 'Sem resultados nos relays configurados.';

  @override
  String get noRecentPostsFromFollowed =>
      'Sem publicações recentes das pessoas que segues.';

  @override
  String get noMomentsFound =>
      'Nenhum momento encontrado nos relays. Verifica a tua ligação.';

  @override
  String get loadFailed => 'Falha ao carregar';

  @override
  String get notifications => 'Notificações';

  @override
  String get messages => 'Mensagens';

  @override
  String get homeEmptyFollowsNobody =>
      'As publicações das pessoas que segues aparecem aqui.\nAinda não segues ninguém: descobre pessoas e perfis interessantes.';

  @override
  String get discoverPeople => 'Descobrir pessoas';

  @override
  String get homeEmpty =>
      'Ainda sem momentos.\nPuxa para baixo para atualizar ou publica a tua primeira foto.';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get seenEverything => 'Já viste tudo por agora ✨';

  @override
  String get discoverMoreProfiles => 'Descobrir mais perfis';

  @override
  String get feedFollowing => 'A seguir';

  @override
  String get signInToSeeFollowed =>
      'Inicia sessão para ver as publicações das pessoas que segues';

  @override
  String get videoPreview => 'Pré-visualização do vídeo';

  @override
  String get cannotOpenPrivateVideo => 'Não é possível abrir o vídeo privado';

  @override
  String get cannotPlayVideo => 'Não é possível reproduzir o vídeo';

  @override
  String get pauseVideo => 'Pausar o vídeo';

  @override
  String get playVideo => 'Reproduzir o vídeo';

  @override
  String errorTapToRetry(Object error) {
    return '$error — toca para tentar de novo';
  }

  @override
  String get soundOn => 'Ligar o som';

  @override
  String get soundOff => 'Desligar o som';

  @override
  String get postImage => 'Imagem da publicação';

  @override
  String get imageUnavailable => 'Imagem indisponível';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nToca para tentar de novo';
  }

  @override
  String get cannotOpenPrivateContent =>
      'Não é possível abrir este conteúdo privado';

  @override
  String get privateImage => 'Imagem privada';

  @override
  String get invalidImage => 'Imagem inválida';

  @override
  String get more => 'Mais';

  @override
  String get removeFromSaved => 'Remover dos guardados';

  @override
  String get copyLink => 'Copiar ligação';

  @override
  String get muteAuthor => 'Silenciar autor';

  @override
  String get blockAuthor => 'Bloquear autor';

  @override
  String get report => 'Denunciar';

  @override
  String get like => 'Gosto';

  @override
  String get sendInMessage => 'Enviar numa mensagem';

  @override
  String get zapOptional => 'Zap (opcional)';

  @override
  String get closeFriendsOnlyNote =>
      'Visível apenas para amigos próximos. Os gostos e as respostas vão só para o autor.';

  @override
  String get likeFailed => 'Não foi possível enviar o gosto';

  @override
  String get nostrLinkCopied =>
      'Ligação Nostr copiada para a área de transferência';

  @override
  String get authorMuted => 'Autor silenciado';

  @override
  String get authorBlocked => 'Autor bloqueado';

  @override
  String get reportSent => 'Denúncia enviada (NIP-56)';

  @override
  String get signInToReport => 'Inicia sessão para denunciar';

  @override
  String minutesAgo(Object minutes) {
    return 'há $minutes min';
  }

  @override
  String get show => 'Mostrar';

  @override
  String get chatEmptyHint =>
      'Escreve a primeira mensagem.\nEstá cifrada: só os dois a conseguem ver.';

  @override
  String get messageHint => 'Mensagem…';

  @override
  String get send => 'Enviar';

  @override
  String get notSentSuffix => ' não enviado';

  @override
  String get contentUnavailable =>
      'Conteúdo indisponível (expirado ou não encontrado nos relays)';

  @override
  String get signInToSendPrivateMessages =>
      'Inicia sessão para enviar mensagens privadas.';

  @override
  String get cannotMessageYourself => 'Não podes escrever para ti próprio.';

  @override
  String get recipientNoPrivateMessages =>
      'Esta pessoa ainda não ativou as mensagens privadas.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Nenhum relay do destinatário aceitou a mensagem$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'O envio falhou: $error';
  }

  @override
  String get signInToReadMessages =>
      'Inicia sessão para ler e enviar mensagens privadas.';

  @override
  String get signerNoPrivateMessagesLong =>
      'As mensagens privadas não podem ser usadas com este início de sessão. Inicia sessão com Amber, um bunker ou a chave local.';

  @override
  String get inboxEmpty =>
      'Sem conversas.\nToca no lápis para escrever a alguém, ou reencaminha um momento com o ícone ✈ por baixo de cada publicação.';

  @override
  String get newMessage => 'Nova mensagem';

  @override
  String get privateMessagesEnabled => 'Mensagens privadas ativadas';

  @override
  String get enableMessagesFailed =>
      'Não foi possível ativá-las. Tenta de novo.';

  @override
  String get enablePrivateMessages => 'Ativar mensagens privadas';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Para receberes mensagens, indica em que relays devem chegar. É publicada uma lista pequena (NIP-17) com $count relays predefinidos: podes mudá-la depois. As mensagens continuam cifradas: os relays não veem quem escreve nem o texto.';
  }

  @override
  String get turnOn => 'Ativar';

  @override
  String get searchByNameOrUsername =>
      'Procurar por nome ou nome de utilizador';

  @override
  String get searching => 'A procurar…';

  @override
  String get noOneWithNameHint =>
      'Ninguém com este nome. Tenta menos letras ou um endereço como name@domain.com.';

  @override
  String get sent => 'Enviado';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviado a $count pessoas',
      one: 'Enviado a 1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviado a $count pessoas. $failure',
      one: 'Enviado a 1 pessoa. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Não podes usar mensagens privadas com este início de sessão.';

  @override
  String get followToStartOrSearch =>
      'Segue alguém para começar, ou procura por nome.';

  @override
  String get addMessage => 'Adiciona uma mensagem…';

  @override
  String sendWithCount(Object count) {
    return 'Enviar ($count)';
  }

  @override
  String get linkCopied => 'Ligação copiada para a área de transferência';

  @override
  String get noNotifications => 'Sem notificações de momento.';

  @override
  String get notificationsDependOnRelays =>
      'As notificações dependem dos relays: podem estar incompletas.';

  @override
  String get reactedToYourMoment => 'reagiu ao teu momento';

  @override
  String commentedText(Object text) {
    return 'comentou: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'enviou-te $sats sats$comment';
  }

  @override
  String get sentYouZap => 'enviou-te um zap';

  @override
  String get startedFollowingYou => 'começou a seguir-te';

  @override
  String get amberNotFound => 'Amber não encontrado';

  @override
  String get amberExplain =>
      'Amber é um assinador Nostr que guarda a tua chave privada fora de Mialuna. Instala-o e tenta de novo.';

  @override
  String get downloadFromFdroid => 'Descarregar do F-Droid';

  @override
  String get continueWithAmber => 'Continuar com Amber';

  @override
  String get amberRecommended =>
      'Recomendado: a tua chave privada fica segura no Amber.';

  @override
  String get amberNotDetected =>
      'Amber não detetado: instala-o para o início de sessão recomendado.';

  @override
  String get exploreWithoutAccount => 'Explorar sem conta';

  @override
  String get remoteBunker => 'Bunker remoto (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'URL de bunker inválido.';

  @override
  String get connectBunker => 'Ligar bunker';

  @override
  String get advancedNsec => 'Início de sessão avançado (nsec)';

  @override
  String get nsecWarning =>
      'Aviso: colar a tua chave privada é arriscado. Nunca a partilhes com ninguém. No Android, prefere o Amber.';

  @override
  String get invalidNsec => 'Chave nsec inválida.';

  @override
  String get signInWithNsec => 'Iniciar sessão com nsec';

  @override
  String get tagline => 'Os teus momentos, sob a mesma lua.';

  @override
  String get skip => 'Saltar';

  @override
  String get permissionsAndWallet => 'Permissões e carteira';

  @override
  String get permissionsExplain =>
      'Servem só para publicares e receberes notificações. Podes mudá-las quando quiseres nas definições do sistema.';

  @override
  String get photosAndVideos => 'Fotos e vídeos';

  @override
  String get toUploadYourMoments => 'Para carregar os teus momentos';

  @override
  String get allow => 'Permitir';

  @override
  String get reactionsCommentsZaps => 'Reações, comentários e zaps';

  @override
  String get lightningWalletOptional => 'Carteira Lightning (opcional)';

  @override
  String get nwcExplain =>
      'Liga uma carteira Nostr Wallet Connect para enviar zaps sem sair da aplicação.';

  @override
  String get walletConnected => 'Carteira ligada';

  @override
  String get disconnect => 'Desligar';

  @override
  String get connectWallet => 'Ligar carteira';

  @override
  String get getStarted => 'Começar';

  @override
  String get welcome1 =>
      'Mialuna é uma rede social visual: fotos, vídeos, Reels e histórias — nunca publicações só de texto.';

  @override
  String get welcome2 =>
      'Funciona com Nostr, um protocolo aberto: a tua identidade é uma chave tua, não uma conta que uma empresa possa tirar-te. Sem anúncios, sem rastreadores, sem servidores centrais.';

  @override
  String get welcome3 =>
      'Partilha a tua luz com pessoas de todo o lado, a partir de qualquer aplicação que fale a mesma língua aberta.';

  @override
  String onboardingWot(int min) {
    return 'A rede de confiança está sempre ligada. A primeira vez que abres Mialuna, lê quem segues e cria o feed Descobrir a partir dessa rede: tu, as pessoas que segues e quem pelo menos $min delas seguem. Nas vezes seguintes em que abres a aplicação, esse feed já está lá.';
  }

  @override
  String get publicAndPrivate => 'Público e privado';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna assenta no Nostr, uma rede aberta. O que publicas é público: publicações, fotos e vídeos ficam visíveis para quem tenha a ligação, mesmo fora de Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Só as pessoas desta lista recebem as tuas publicações, histórias e vídeos de \"Amigos próximos\". A lista vai dentro da publicação; não tens de a escolher de cada vez.';

  @override
  String get closeFriendsExplain2 =>
      'As fotos e os vídeos são cifrados no teu telemóvel antes de serem carregados. Os servidores de ficheiros (Blossom) não cifram nada por si: por isso Mialuna fá-lo, e o servidor só vê dados ilegíveis. Quem encontrar o endereço do ficheiro não o consegue abrir.';

  @override
  String get closeFriendsExplain3 =>
      'Não é uma garantia absoluta: quem recebe uma publicação pode fazer uma captura de ecrã, e remover um amigo só vale para publicações futuras.';

  @override
  String get closeFriendsExplain4 =>
      'Cada amigo tem de usar Mialuna com as mensagens privadas ativadas. Outros clientes Nostr não mostram estas publicações.';

  @override
  String get closeFriendsExplain5 =>
      'As publicações públicas continuam públicas: os ficheiros ficam visíveis para quem tenha a ligação.';

  @override
  String get closeFriendsExplain6 =>
      'Se nenhum dos teus servidores aceitar ficheiros cifrados, a publicação não sai: nunca em claro.';

  @override
  String get addToCloseFriends => 'Adicionar a amigos próximos';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Limite de $max amigos: $added adicionados.';
  }

  @override
  String get add => 'Adicionar';

  @override
  String get signInToCreateList => 'Inicia sessão para criar a tua lista.';

  @override
  String get signerNoCloseFriends =>
      'Os amigos próximos não podem ser usados com este início de sessão. Inicia sessão com Amber, um bunker ou a chave local.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max pessoas';
  }

  @override
  String get noOneYet => 'Ainda ninguém.';

  @override
  String get addPeople => 'Adicionar pessoas';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Não ativaram as mensagens privadas: não vão receber as tuas publicações';

  @override
  String get removeFromList => 'Remover da lista';

  @override
  String get noOneWithThisName => 'Ninguém com este nome.';

  @override
  String get signInToSendPrivateContent =>
      'Inicia sessão para enviar conteúdo privado.';

  @override
  String get reasonNoPrivateMessages => 'não ativou as mensagens privadas';

  @override
  String get reasonNoRelayAnswered => 'nenhum relay respondeu';

  @override
  String get profileUpdated => 'Perfil atualizado';

  @override
  String get noRelayAcceptedRetry => 'Nenhum relay aceitou. Tenta mais tarde.';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get fieldName => 'Nome';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'URL do avatar';

  @override
  String get fieldNip05 => 'NIP-05 (p. ex. you@example.com)';

  @override
  String get browsingAsGuest => 'Estás a navegar como convidado';

  @override
  String get signInToInteract =>
      'Inicia sessão para publicar, seguir e interagir.';

  @override
  String get settings => 'Definições';

  @override
  String get signOut => 'Terminar sessão';

  @override
  String get npubCopied => 'npub copiado';

  @override
  String get copyNpub => 'Copiar npub';

  @override
  String get mute => 'Silenciar';

  @override
  String get block => 'Bloquear';

  @override
  String get posts => 'Publicações';

  @override
  String get saved => 'Guardados';

  @override
  String get nothingPublishedYet => 'Ainda não publicaste nada.';

  @override
  String get noPostsOnRelays => 'Nenhuma publicação encontrada nos relays.';

  @override
  String get noReelsPublished => 'Nenhum reel publicado.';

  @override
  String get noReelsOnRelays => 'Nenhum reel encontrado nos relays.';

  @override
  String get noSavedPosts => 'Sem publicações guardadas.';

  @override
  String get followingButton => 'A seguir';

  @override
  String get follow => 'Seguir';

  @override
  String get messageButton => 'Mensagem';

  @override
  String get loginLocalKey => 'Chave local';

  @override
  String get loginGuest => 'Convidado';

  @override
  String get followUpdateFailed =>
      'Não foi possível atualizar quem segues agora. Tenta de novo.';

  @override
  String get noReelsComeBack =>
      'Nenhum reel encontrado nos relays.\nVolta em breve!';

  @override
  String get followUpdateFailedShort =>
      'Não foi possível atualizar quem segues agora';

  @override
  String get needOneReadRelay => 'É necessário pelo menos um relay de leitura.';

  @override
  String get listSavedLocally =>
      'Lista guardada neste dispositivo, não publicada.';

  @override
  String get noRelayAcceptedList =>
      'Nenhum relay aceitou a lista: será tentado de novo mais tarde.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay list publicada em $count relays',
      one: 'Relay list publicada em 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Servidores de multimédia atualizados';

  @override
  String get appearance => 'Aspeto';

  @override
  String get publishingSettings => 'Publicação';

  @override
  String get addMialunaHashtag => 'Adicionar #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Adiciona a hashtag oficial às publicações e histórias públicas. Podes desligar isto quando quiseres.';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays guardam e distribuem o conteúdo. Inicia sessão para usar a tua própria lista automaticamente (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'A lista está sincronizada com o teu perfil Nostr (NIP-65): cada alteração é publicada e aplica-se a todas as tuas aplicações.';

  @override
  String get syncing => 'A sincronizar…';

  @override
  String get waitingFirstSync => 'À espera da primeira sincronização';

  @override
  String get syncNow => 'Sincronizar agora';

  @override
  String get addRelay => 'Adicionar relay';

  @override
  String get restoreDefaultRelays => 'Repor os relays predefinidos';

  @override
  String get createYourList => 'Criar a tua lista';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Publicações, histórias e vídeos visíveis só para eles, com fotos e vídeos cifrados.';

  @override
  String get mediaServersBlossom => 'Servidores de multimédia (Blossom)';

  @override
  String get mediaServersExplain =>
      'As fotos e os vídeos são carregados só para estes servidores, na ordem mostrada: ganha o primeiro que os aceitar. EXIF e a localização são removidos antes do carregamento.';

  @override
  String get primary => 'Principal';

  @override
  String get makePrimary => 'Tornar principal';

  @override
  String get remove => 'Remover';

  @override
  String get addServer => 'Adicionar servidor';

  @override
  String get moderation => 'Moderação';

  @override
  String get moderationExplain =>
      'Autores silenciados e hashtags ocultas sincronizam-se via NIP-51. Os autores bloqueados ficam só neste dispositivo.';

  @override
  String get mutedAuthors => 'Autores silenciados';

  @override
  String get noMutedAuthors => 'Sem autores silenciados';

  @override
  String get blockedAuthors => 'Autores bloqueados';

  @override
  String get noBlockedAuthors => 'Sem autores bloqueados';

  @override
  String get hiddenHashtags => 'Hashtags ocultas';

  @override
  String get noHiddenHashtags => 'Sem hashtags ocultas';

  @override
  String get hashtagToHide => '#hashtag a ocultar';

  @override
  String get storage => 'Armazenamento';

  @override
  String get clearCache => 'Limpar a cache de eventos e os rascunhos';

  @override
  String get cacheCleared => 'Cache limpa';

  @override
  String get reviewIntro => 'Rever a introdução';

  @override
  String get reviewIntroSubtitle =>
      'O que é público, o que é privado e os limites dos amigos próximos.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Nenhuma carteira Lightning encontrada: endereço copiado ($address)';
  }

  @override
  String get about => 'Acerca de';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Os teus momentos, sob a mesma lua.\nCódigo aberto (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Endereço inválido: usa wss://…';

  @override
  String get invalidServerAddress => 'Endereço inválido: usa https://…';

  @override
  String get relayRead => 'Leitura';

  @override
  String get relayWrite => 'Escrita';

  @override
  String get support => 'Apoio';

  @override
  String get supportText =>
      'Mialuna é gratuito, não tem anúncios e não te rastreia. Se gostares, podes enviar uns sats pela rede Lightning.';

  @override
  String get donateWithLightning => 'Doar com Lightning';

  @override
  String get authorNoZaps => 'Este autor não aceita zaps';

  @override
  String get sendZap => 'Enviar um zap ⚡';

  @override
  String get amountInSats => 'Montante em sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'mín. $min – máx. $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Inicia sessão para enviar zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap de $sats sats enviado ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'O pagamento NWC falhou: $error';
  }

  @override
  String get noLightningWallet => 'Nenhuma carteira Lightning encontrada';

  @override
  String storiesRailLabel(Object state) {
    return 'Histórias, $state';
  }

  @override
  String get close => 'Fechar';

  @override
  String hoursAgo(int hours) {
    return 'há $hours h';
  }

  @override
  String daysAgo(int days) {
    return 'há $days d';
  }

  @override
  String get now => 'agora';

  @override
  String get youPrefix => 'Tu: ';

  @override
  String get storiesStateUnseen => 'novas';

  @override
  String get storiesStateSeen => 'vistas';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'seg',
      'tue': 'ter',
      'wed': 'qua',
      'thu': 'qui',
      'fri': 'sex',
      'sat': 'sáb',
      'sun': 'dom',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Partilhou um momento';

  @override
  String get blossomOtherError => 'erro';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Esta foto não pode ser editada aqui.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notificações novas',
      one: '1 notificação nova',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens por ler',
      one: '1 mensagem por ler',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Feito';

  @override
  String get storyAddText => 'Adicionar texto';

  @override
  String get storyEditText => 'Editar texto';

  @override
  String get storyTextHint => 'Escreve algo… os #hashtags podem ser tocados';

  @override
  String get storyTextsHelp =>
      'Toca na imagem para escrever. Arrasta para mover, belisca para redimensionar e rodar, toca num texto para o editar.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count textos',
      one: '1 texto',
      zero: 'Sem texto',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Clássico';

  @override
  String get storyFontBold => 'Negrito';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Itálico';

  @override
  String get storyTextBackground => 'Fundo do texto';

  @override
  String get storyTextColor => 'Cor do texto';

  @override
  String storyTextLimit(int max) {
    return 'Podes adicionar até $max textos.';
  }

  @override
  String get wotTitle => 'Rede de confiança';

  @override
  String get wotEnable => 'A rede de confiança está sempre ligada';

  @override
  String wotExplain(int min) {
    return 'Sempre ligada. Descobrir mostra só esta rede: tu, as pessoas que segues e quem é seguido por pelo menos $min delas. A mesma rede oculta comentários, notificações, publicações privadas e mensagens de toda a gente. É calculada neste telemóvel a partir das listas públicas de seguidos na primeira vez que abres a aplicação; as aberturas seguintes reutilizam-na. Nada é enviado para nenhum servidor.';
  }

  @override
  String get wotRefresh => 'Atualizar a rede agora';

  @override
  String get wotStatusIdle =>
      'Ainda não foi criada. É criada na primeira vez que abres a aplicação.';

  @override
  String get wotBuildingTitle => 'A construir o teu feed Descobrir';

  @override
  String get wotBuildingBody =>
      'A ler quem as pessoas que segues também seguem e a preparar o Descobrir.';

  @override
  String get wotDiscoverHint =>
      'Só a tua rede de confiança: pessoas que segues e pessoas que bastantes delas seguem.';

  @override
  String get wotDiscoverSignIn =>
      'Descobrir mostra a tua rede de confiança. Inicia sessão e, da primeira vez, Mialuna lê quem segues e constrói este feed. As aberturas seguintes reutilizam-no.';

  @override
  String get wotDiscoverEmpty =>
      'Ainda sem publicações da tua rede de confiança.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'A verificar quem os teus seguidos seguem… $done de $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'A tua rede: $direct pessoas que segues mais $indirect seguidas por bastantes delas. Atualizada $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Não foi possível calcular a tua rede: $reason';
  }

  @override
  String get wotNoFollows => 'ainda não segues ninguém';

  @override
  String get messageRequests => 'Pedidos de mensagem';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversas de fora da tua rede de confiança',
      one: '1 conversa de fora da tua rede de confiança',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'De pessoas fora da tua rede de confiança. Não contam como por ler. Responde para mover uma conversa para a caixa de entrada.';

  @override
  String get storyViewsSetting => 'Deixar ver que vi as histórias deles';

  @override
  String get storyViewsSettingExplain =>
      'Quando vês uma história, é enviado um recibo ao autor, cifrado para que só essa pessoa o possa ler. Mostra o teu nome ao lado do dela; os relays não veem nada. Se não puder ser entregue, fica guardado e tenta-se de novo mais tarde. Desliga para veres sem avisar ninguém: os recibos ainda não enviados são descartados (um já entregue não pode ser retirado).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vista por $count pessoas',
      one: 'Vista por 1 pessoa',
      zero: 'Ainda sem visualizações',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Ainda ninguém viu esta história, ou os recibos ainda não te chegaram.';

  @override
  String get storyViewsHint =>
      'Só quem permite envia um recibo, por isso o número real pode ser maior.';

  @override
  String get systemNotifications => 'Notificações do sistema';

  @override
  String get systemNotificationsExplain =>
      'Mostra uma notificação no teu telemóvel quando chega algo novo e Mialuna está em segundo plano. As mensagens privadas nunca mostram o texto, nem no ecrã de bloqueio. O Android pausa aplicações que ficam muito tempo em segundo plano, por isso as notificações chegam enquanto Mialuna ainda está a correr.';

  @override
  String get systemNotificationsBlocked =>
      'As notificações estão desligadas para Mialuna nas definições do telemóvel.';

  @override
  String get systemNotificationsOpenSettings => 'Abrir definições';

  @override
  String get systemNotificationsBattery =>
      'O Android põe as aplicações a dormir uns minutos depois de o ecrã se desligar, e as notificações param com elas. Para continuares a recebê-las, define a utilização da bateria de Mialuna como “Sem restrições”.';

  @override
  String get systemNotificationsBatteryAction => 'Abrir definições da bateria';

  @override
  String get newFollowersSetting => 'Mostrar novos seguidores';

  @override
  String get newFollowersSettingExplain =>
      'Os novos seguidores aparecem nas Notificações e no teu telemóvel. Desliga se as pessoas te inundarem de seguimentos: gostos, comentários e zaps continuam a aparecer.';

  @override
  String get systemNotificationMessage => 'enviou-te uma mensagem privada';

  @override
  String get systemNotificationNewMessage => 'Nova mensagem privada';

  @override
  String get systemNotificationNew => 'Nova notificação';

  @override
  String get notificationChannelSocial =>
      'Reações, comentários, zaps e seguidores';

  @override
  String get notificationChannelMessages => 'Mensagens privadas';

  @override
  String get zapInvoiceMismatch =>
      'A fatura não corresponde ao montante que escolheste. Nada foi pago.';

  @override
  String get storyYourStory => 'A tua história';

  @override
  String get storyNew => 'Nova história';

  @override
  String get storyAddSemantics => 'Adicionar à tua história';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count histórias',
      one: '1 história',
    );
    return 'A tua história, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Tamanho do texto';

  @override
  String get storyPickPrompt =>
      'Escolhe uma foto ou um vídeo para a tua história';

  @override
  String get storyEditPhoto => 'Editar foto';

  @override
  String get storyCaption => 'Legenda';

  @override
  String get storyDiscardTitle => 'Descartar esta história?';

  @override
  String get storyDiscard => 'Descartar';

  @override
  String get storyShare => 'Partilhar';

  @override
  String get storyShared => 'História partilhada';

  @override
  String get deletePost => 'Eliminar';

  @override
  String get deletePostTitle => 'Eliminar esta publicação?';

  @override
  String get deleteStoryTitle => 'Eliminar esta história?';

  @override
  String get deletePostBody =>
      'Mialuna vai pedir aos teus relays para a eliminar e aos servidores de multimédia para eliminar as fotos ou o vídeo. Um relay que ignore o pedido, ou alguém que já tenha guardado uma cópia, pode ainda tê-la.';

  @override
  String get deletePrivateBody =>
      'Uma publicação de amigos próximos não pode ser retirada dos relays. Mialuna vai pedir às aplicações dos teus amigos para a remover e ao servidor de multimédia para eliminar os ficheiros cifrados. Um amigo que já tenha guardado uma cópia pode ainda tê-la.';

  @override
  String get deletingPost => 'A eliminar…';

  @override
  String get postDeleted => 'Eliminado.';

  @override
  String get postWasDeleted => 'Esta publicação foi eliminada.';

  @override
  String get deleteNotAllowed => 'Só a conta que a publicou a pode eliminar.';

  @override
  String deleteFailed(Object reason) {
    return 'Não foi possível eliminar: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Nenhum relay aceitou o pedido de eliminação, por isso continua online. Verifica a ligação e tenta de novo.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Não foi possível remover a multimédia de $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'O teu assinador não autorizou remover a multimédia, por isso os ficheiros continuam no servidor de multimédia.';

  @override
  String deleteFriendsMissed(Object count) {
    return 'Não foi possível avisar $count dos teus amigos próximos, por isso pode ficar nos telemóveis deles.';
  }

  @override
  String get storyCleanupSetting =>
      'Eliminar as minhas histórias quando expiram';

  @override
  String get storyCleanupSettingExplain =>
      'Ao fim de 24 horas, Mialuna pede aos teus relays e aos teus servidores de multimédia para eliminar as tuas histórias, fotos e vídeos incluídos. Um servidor que ignore o pedido, ou alguém que tenha guardado uma cópia, pode ainda tê-las.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'O teu assinador tem de aprovar cada limpeza, por isso espera até pedires. Histórias expiradas em espera: $count.';
  }

  @override
  String get storyCleanupNow => 'Eliminar agora';

  @override
  String get storyCleanupDone => 'Histórias expiradas eliminadas.';

  @override
  String get storyCleanupPartly =>
      'Algumas ainda não puderam ser eliminadas; Mialuna vai tentar de novo.';
}
