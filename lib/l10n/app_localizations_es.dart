// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get syncUpToDate => 'Al día';

  @override
  String get syncFailed => 'Error al sincronizar';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays actualizados desde tu perfil (NIP-65)';

  @override
  String get relayListPublished => 'Relay list publicada';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Servidores de medios actualizados desde tu perfil';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Descubrir';

  @override
  String get tabCreate => 'Crear';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Perfil';

  @override
  String get signInToUploadMedia => 'Inicia sesión para subir archivos.';

  @override
  String get noMediaServer =>
      'Ningún servidor de medios configurado. Añade uno en Ajustes.';

  @override
  String serverNoResponse(Object server) {
    return '$server: sin respuesta';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: inaccesible ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Subida rechazada — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Ningún servidor aceptó el archivo — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'respuesta no válida';

  @override
  String get blossomInvalidFileUrl => 'dirección de archivo no válida';

  @override
  String get blossomServerAlteredFile => 'el servidor modificó el archivo';

  @override
  String get blossomBadRequest => 'solicitud no válida';

  @override
  String get blossomUnauthorized => 'autorización denegada';

  @override
  String get blossomPaymentRequired => 'pago necesario';

  @override
  String get blossomForbidden => 'no permitido';

  @override
  String get blossomLengthRequired => 'falta el tamaño';

  @override
  String get blossomTooLarge => 'archivo demasiado grande';

  @override
  String get blossomUnsupportedType => 'formato no aceptado';

  @override
  String get blossomTooManyRequests => 'demasiadas solicitudes';

  @override
  String get blossomServerError => 'error del servidor';

  @override
  String get cipherInvalidKey => 'Clave no válida';

  @override
  String get cipherTruncated => 'El archivo cifrado está truncado';

  @override
  String get cipherMismatch =>
      'El archivo no coincide con la clave: modificado o dañado';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Formato HEIC/AVIF: la conversión requiere sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'El vídeo WebM/MKV no es compatible: usa MP4 o MOV para quitar los metadatos antes de subirlo.';

  @override
  String get sanitizeUnknownFormat =>
      'Formato no reconocido: fotos JPEG/PNG/WebP/GIF o vídeos MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'No se pudieron quitar todos los metadatos ($items): archivo no subido.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'No se pudo procesar el archivo: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'JPEG no válido';

  @override
  String get sanitizeJpegTruncated => 'JPEG truncado';

  @override
  String get sanitizeJpegNoSize => 'JPEG sin dimensiones';

  @override
  String get sanitizeJpegUndecodable => 'El JPEG no se puede decodificar';

  @override
  String get sanitizePngTruncated => 'PNG truncado';

  @override
  String get sanitizePngInvalid => 'PNG no válido';

  @override
  String get sanitizeGifInvalid => 'GIF no válido';

  @override
  String get sanitizeGifTruncated => 'GIF truncado';

  @override
  String get sanitizeWebpTruncated => 'WebP truncado';

  @override
  String get sanitizeWebpInvalid => 'WebP no válido';

  @override
  String get sanitizeMp4Invalid => 'Vídeo MP4/MOV no válido';

  @override
  String get sanitizeConversionFailed => 'La conversión falló';

  @override
  String get sanitizeHeifUnsupported =>
      'Este formato (HEIC/AVIF) no se puede convertir en este dispositivo. Elige una foto JPEG o PNG.';

  @override
  String get privateMediaNotEncrypted => 'El archivo no está cifrado';

  @override
  String serverReplied(Object status) {
    return 'El servidor respondió $status';
  }

  @override
  String get fileTooLarge => 'Archivo demasiado grande';

  @override
  String get serverFileNotOriginal =>
      'El archivo del servidor no es el original';

  @override
  String get contentMismatch => 'El contenido no coincide';

  @override
  String get mediaUnreachable => 'Medio inaccesible';

  @override
  String get amberInvalidKey => 'Amber devolvió una clave no válida';

  @override
  String get amberNoKey => 'Amber no devolvió una clave';

  @override
  String get amberRequestRejected => 'Solicitud rechazada en Amber';

  @override
  String get amberAndroidOnly => 'Amber solo está disponible en Android';

  @override
  String get amberEmptySignature => 'Amber devolvió una firma vacía';

  @override
  String get amberSignRejected => 'Firma rechazada en Amber';

  @override
  String get amberTimeout => 'Amber no respondió a tiempo';

  @override
  String get amberEmptyResponse => 'Amber devolvió una respuesta vacía';

  @override
  String get bunkerInvalidUrl => 'URL de bunker no válida';

  @override
  String get bunkerNoRelay => 'El bunker no indica ningún relay';

  @override
  String get bunkerWebAuth =>
      'El bunker exige autorización web (auth_url no es compatible)';

  @override
  String get bunkerInvalidKey => 'El bunker no devolvió una clave válida';

  @override
  String get signerInvalidResponse =>
      'El firmante devolvió un evento firmado no válido';

  @override
  String get bunkerTimeout => 'Bunker agotó el tiempo de espera';

  @override
  String get nwcInvalidUri => 'URI NWC no válida';

  @override
  String get nwcNoRelay => 'La URI NWC no indica ningún relay';

  @override
  String get nwcNoSecret => 'La URI NWC no contiene un secreto válido';

  @override
  String get nwcTimeout => 'El monedero agotó el tiempo de espera';

  @override
  String get signerNoPrivateMessages =>
      'Este inicio de sesión no admite mensajes privados';

  @override
  String get zapNotSupported => 'Esta dirección no admite zaps de Nostr';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Importe fuera de rango ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Comentario no enviado. Inténtalo más tarde.';

  @override
  String get comments => 'Comentarios';

  @override
  String get noCommentsYet => 'Aún no hay comentarios.';

  @override
  String get signInToComment => 'Inicia sesión para comentar.';

  @override
  String get addComment => 'Añade un comentario…';

  @override
  String get signInToPublish => 'Inicia sesión para publicar.';

  @override
  String get addMediaFirst =>
      'Añade al menos una foto o un vídeo antes de publicar.';

  @override
  String get removingMetadata => 'Quitando metadatos…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Subiendo $current de $total…';
  }

  @override
  String get creatingPreview => 'Creando la vista previa…';

  @override
  String uploadFailed(Object error) {
    return 'Error al subir: $error';
  }

  @override
  String get publishing => 'Publicando…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Ningún relay aceptó la publicación$reason. El contenido sigue en tus borradores.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Este inicio de sesión no admite contenido privado. Usa Amber, un bunker o la clave local.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Tu lista de amigos cercanos está vacía: añade a alguien.';

  @override
  String get fileOver100Mb =>
      'El archivo supera los 100 MB: es el límite para amigos cercanos (se cifra entero en tu teléfono).';

  @override
  String get encryptingOnPhone => 'Cifrando en tu teléfono…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Ninguno de tus servidores de medios aceptó el archivo cifrado. No se publica en claro. Añade en Ajustes un servidor que acepte archivos cifrados (por ejemplo cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Enviando a amigos…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Enviando a amigos $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Ningún amigo recibió la publicación$reason. El contenido sigue en tus borradores.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviado a $count amigos cercanos 🔒',
      one: 'Enviado a 1 amigo cercano 🔒',
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
    return '$_temp0 $missed no lo recibieron (los mensajes privados están desactivados).';
  }

  @override
  String get altText => 'Texto alternativo';

  @override
  String get altTextHint => 'Describe el contenido para quien no pueda verlo…';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get momentPublished => 'Momento publicado ✨';

  @override
  String get newMoment => 'Nuevo momento';

  @override
  String get publish => 'Publicar';

  @override
  String get guestMode => 'Modo invitado';

  @override
  String get signInToPostMoments => 'Inicia sesión para publicar tus momentos.';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get kindPhoto => 'Foto';

  @override
  String get kindVideo => 'Vídeo';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Historia';

  @override
  String get storyExpiryNote =>
      'Las historias caducan a las 24 horas en los relays que respetan NIP-40, pero otros pueden guardarlas o archivarlas.';

  @override
  String get fromGallery => 'De la galería';

  @override
  String get galleryLongPressVideo => 'Galería (mantén pulsado para vídeo)';

  @override
  String get addVideo => 'Añadir vídeo';

  @override
  String get camera => 'Cámara';

  @override
  String get exifRemovedNote =>
      'Los metadatos de ubicación (EXIF) se quitan automáticamente.';

  @override
  String get writeCaption => 'Escribe un pie…';

  @override
  String get privatePostNote =>
      'Publicación privada: sin hashtags públicos, no se encuentra en la búsqueda.';

  @override
  String willPublishAs(Object caption) {
    return 'Se publicará como: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Toca una miniatura para añadir el texto alternativo.';

  @override
  String get sensitiveContent => 'Contenido sensible';

  @override
  String get sensitiveContentNote =>
      'La publicación se ocultará tras un aviso (NIP-36).';

  @override
  String get uploadingMedia => 'Subiendo archivos…';

  @override
  String get audiencePublic => 'Público';

  @override
  String get closeFriends => 'Amigos cercanos';

  @override
  String get signerCannotPublishCloseFriends =>
      'Con este inicio de sesión no puedes publicar para amigos cercanos: usa Amber, un bunker o la clave local.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Tu lista está vacía: añade a quien pueda ver esta publicación.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Solo tus $count amigos cercanos verán esto. Las fotos y los vídeos se cifran en tu teléfono antes de subirse.',
      one: 'Solo tu 1 amigo cercano verá esto. Las fotos y los vídeos se cifran en tu teléfono antes de subirse.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Añadir amigos';

  @override
  String get manageList => 'Gestionar la lista';

  @override
  String get edit => 'Editar';

  @override
  String get reset => 'Restablecer';

  @override
  String get apply => 'Aplicar';

  @override
  String get cropFree => 'Libre';

  @override
  String get cropOriginal => 'Original';

  @override
  String get rotate => 'Girar';

  @override
  String get flip => 'Voltear';

  @override
  String get brightness => 'Brillo';

  @override
  String get contrast => 'Contraste';

  @override
  String get saturation => 'Saturación';

  @override
  String postsByAuthor(Object author) {
    return 'Publicaciones de $author…';
  }

  @override
  String get searchHint => 'Busca personas, hashtags o palabras…';

  @override
  String get clear => 'Borrar';

  @override
  String get recent => 'Recientes';

  @override
  String get searchDependsOnRelays =>
      'La búsqueda depende de los relays configurados: los resultados pueden ser parciales.';

  @override
  String get recentPostsEverywhere =>
      'Publicaciones recientes de toda la red, también de gente a la que no sigues.';

  @override
  String get noResultsOnRelays =>
      'No hay resultados en los relays configurados.';

  @override
  String get noRecentPostsFromFollowed =>
      'No hay publicaciones recientes de las personas a las que sigues.';

  @override
  String get noMomentsFound =>
      'No hay momentos en los relays. Comprueba tu conexión.';

  @override
  String get loadFailed => 'Error al cargar';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get messages => 'Mensajes';

  @override
  String get homeEmptyFollowsNobody =>
      'Las publicaciones de quienes sigues aparecen aquí.\nAún no sigues a nadie: descubre gente y perfiles interesantes.';

  @override
  String get discoverPeople => 'Descubrir personas';

  @override
  String get homeEmpty =>
      'Aún no hay momentos.\nDesliza hacia abajo para actualizar o publica tu primera foto.';

  @override
  String get retry => 'Reintentar';

  @override
  String get seenEverything => 'Ya lo has visto todo por ahora ✨';

  @override
  String get discoverMoreProfiles => 'Descubrir más perfiles';

  @override
  String get feedFollowing => 'Siguiendo';

  @override
  String get signInToSeeFollowed =>
      'Inicia sesión para ver las publicaciones de quienes sigues';

  @override
  String get videoPreview => 'Vista previa del vídeo';

  @override
  String get cannotOpenPrivateVideo => 'No se puede abrir el vídeo privado';

  @override
  String get cannotPlayVideo => 'No se puede reproducir el vídeo';

  @override
  String get pauseVideo => 'Pausar el vídeo';

  @override
  String get playVideo => 'Reproducir el vídeo';

  @override
  String errorTapToRetry(Object error) {
    return '$error — toca para reintentar';
  }

  @override
  String get soundOn => 'Activar el sonido';

  @override
  String get soundOff => 'Silenciar el sonido';

  @override
  String get postImage => 'Imagen de la publicación';

  @override
  String get imageUnavailable => 'Imagen no disponible';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nToca para reintentar';
  }

  @override
  String get cannotOpenPrivateContent =>
      'No se puede abrir este contenido privado';

  @override
  String get privateImage => 'Imagen privada';

  @override
  String get invalidImage => 'Imagen no válida';

  @override
  String get more => 'Más';

  @override
  String get removeFromSaved => 'Quitar de guardados';

  @override
  String get copyLink => 'Copiar enlace';

  @override
  String get muteAuthor => 'Silenciar autor';

  @override
  String get blockAuthor => 'Bloquear autor';

  @override
  String get report => 'Denunciar';

  @override
  String get like => 'Me gusta';

  @override
  String get sendInMessage => 'Enviar en un mensaje';

  @override
  String get zapOptional => 'Zap (opcional)';

  @override
  String get closeFriendsOnlyNote =>
      'Visible solo para amigos cercanos. Los me gusta y las respuestas van solo al autor.';

  @override
  String get likeFailed => 'No se pudo enviar el me gusta';

  @override
  String get nostrLinkCopied => 'Enlace de Nostr copiado al portapapeles';

  @override
  String get authorMuted => 'Autor silenciado';

  @override
  String get authorBlocked => 'Autor bloqueado';

  @override
  String get reportSent => 'Denuncia enviada (NIP-56)';

  @override
  String get signInToReport => 'Inicia sesión para denunciar';

  @override
  String minutesAgo(Object minutes) {
    return 'hace $minutes min';
  }

  @override
  String get show => 'Mostrar';

  @override
  String get chatEmptyHint =>
      'Escribe el primer mensaje.\nEstá cifrado: solo vosotros dos podéis verlo.';

  @override
  String get messageHint => 'Mensaje…';

  @override
  String get send => 'Enviar';

  @override
  String get notSentSuffix => ' no enviado';

  @override
  String get contentUnavailable =>
      'Contenido no disponible (caducado o no encontrado en los relays)';

  @override
  String get signInToSendPrivateMessages =>
      'Inicia sesión para enviar mensajes privados.';

  @override
  String get cannotMessageYourself => 'No puedes escribirte a ti mismo.';

  @override
  String get recipientNoPrivateMessages =>
      'Esta persona aún no ha activado los mensajes privados.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Ningún relay del destinatario aceptó el mensaje$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Error al enviar: $error';
  }

  @override
  String get signInToReadMessages =>
      'Inicia sesión para leer y enviar mensajes privados.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Con este inicio de sesión no hay mensajes privados. Inicia sesión con Amber, un bunker o la clave local.';

  @override
  String get inboxEmpty =>
      'No hay conversaciones.\nToca el lápiz para escribir a alguien, o reenvía un momento con el icono ✈ bajo cada publicación.';

  @override
  String get newMessage => 'Nuevo mensaje';

  @override
  String get privateMessagesEnabled => 'Mensajes privados activados';

  @override
  String get enableMessagesFailed =>
      'No se han podido activar. Inténtalo de nuevo.';

  @override
  String get enablePrivateMessages => 'Activar mensajes privados';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Para recibir mensajes indica en qué relays deben llegar. Se publica una lista breve (NIP-17) con $count relays predeterminados: puedes cambiarla después. Los mensajes siguen cifrados: los relays no ven quién escribe ni el texto.';
  }

  @override
  String get turnOn => 'Activar';

  @override
  String get searchByNameOrUsername => 'Buscar por nombre o usuario';

  @override
  String get searching => 'Buscando…';

  @override
  String get noOneWithNameHint =>
      'Nadie con este nombre. Prueba con menos letras o una dirección como name@domain.com.';

  @override
  String get sent => 'Enviado';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviado a $count personas',
      one: 'Enviado a 1 persona',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviado a $count personas. $failure',
      one: 'Enviado a 1 persona. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'No puedes usar mensajes privados con este inicio de sesión.';

  @override
  String get followToStartOrSearch =>
      'Sigue a alguien para empezar, o busca por nombre.';

  @override
  String get addMessage => 'Añade un mensaje…';

  @override
  String sendWithCount(Object count) {
    return 'Enviar ($count)';
  }

  @override
  String get linkCopied => 'Enlace copiado al portapapeles';

  @override
  String get noNotifications => 'No hay notificaciones ahora mismo.';

  @override
  String get notificationsDependOnRelays =>
      'Las notificaciones dependen de los relays: pueden estar incompletas.';

  @override
  String get reactedToYourMoment => 'reaccionó a tu momento';

  @override
  String commentedText(Object text) {
    return 'comentó: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'te envió $sats sats$comment';
  }

  @override
  String get sentYouZap => 'te envió un zap';

  @override
  String get startedFollowingYou => 'empezó a seguirte';

  @override
  String get amberNotFound => 'Amber no encontrado';

  @override
  String get amberExplain =>
      'Amber es un firmante Nostr que guarda tu clave privada fuera de Mialuna. Instálalo e inténtalo de nuevo.';

  @override
  String get downloadFromFdroid => 'Descargar de F-Droid';

  @override
  String get continueWithAmber => 'Continuar con Amber';

  @override
  String get amberRecommended =>
      'Recomendado: tu clave privada queda a salvo en Amber.';

  @override
  String get amberNotDetected =>
      'Amber no detectado: instálalo para el inicio de sesión recomendado.';

  @override
  String get exploreWithoutAccount => 'Explorar sin cuenta';

  @override
  String get remoteBunker => 'Bunker remoto (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'URL de bunker no válida.';

  @override
  String get connectBunker => 'Conectar bunker';

  @override
  String get advancedNsec => 'Inicio de sesión avanzado (nsec)';

  @override
  String get nsecWarning =>
      'Aviso: pegar tu clave privada es arriesgado. No la compartas con nadie. En Android, mejor Amber.';

  @override
  String get invalidNsec => 'Clave nsec no válida.';

  @override
  String get signInWithNsec => 'Iniciar sesión con nsec';

  @override
  String get tagline => 'Tus momentos, bajo la misma luna.';

  @override
  String get skip => 'Omitir';

  @override
  String get permissionsAndWallet => 'Permisos y monedero';

  @override
  String get permissionsExplain =>
      'Solo sirven para publicar y recibir notificaciones. Puedes cambiarlos cuando quieras en los ajustes del sistema.';

  @override
  String get photosAndVideos => 'Fotos y vídeos';

  @override
  String get toUploadYourMoments => 'Para subir tus momentos';

  @override
  String get allow => 'Permitir';

  @override
  String get reactionsCommentsZaps => 'Reacciones, comentarios y zaps';

  @override
  String get lightningWalletOptional => 'Monedero Lightning (opcional)';

  @override
  String get nwcExplain =>
      'Conecta un monedero Nostr Wallet Connect para enviar zaps sin salir de la aplicación.';

  @override
  String get walletConnected => 'Monedero conectado';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get connectWallet => 'Conectar monedero';

  @override
  String get getStarted => 'Empezar';

  @override
  String get welcome1 =>
      'Mialuna es una red social visual: fotos, vídeos, Reels e historias, nunca publicaciones solo de texto.';

  @override
  String get welcome2 =>
      'Funciona con Nostr, un protocolo abierto: tu identidad es una clave tuya, no una cuenta que una empresa pueda quitarte. Sin anuncios, sin rastreadores, sin servidores centrales.';

  @override
  String get welcome3 =>
      'Comparte tu luz con gente de todas partes, desde cualquier aplicación que hable el mismo idioma abierto.';

  @override
  String onboardingWot(int min) {
    return 'La red de confianza está siempre activa. La primera vez que abres Mialuna lee a quién sigues y crea el feed Descubrir con esa red: tú, las personas a las que sigues y a quien siguen al menos $min de ellas. Las siguientes veces que abras la aplicación, ese feed ya está listo.';
  }

  @override
  String get publicAndPrivate => 'Público y privado';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna se basa en Nostr, una red abierta. Lo que publicas es público: publicaciones, fotos y vídeos siguen visibles para quien tenga el enlace, incluso fuera de Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Solo la gente de esta lista recibe tus publicaciones, historias y vídeos de \"Amigos cercanos\". La lista va dentro de la publicación; no hace falta elegirla cada vez.';

  @override
  String get closeFriendsExplain2 =>
      'Las fotos y los vídeos se cifran en tu teléfono antes de subirse. Los servidores de archivos (Blossom) no cifran nada por sí mismos: por eso lo hace Mialuna, y el servidor solo ve datos ilegibles. Quien tenga la dirección del archivo no puede abrirlo.';

  @override
  String get closeFriendsExplain3 =>
      'No es una garantía absoluta: quien recibe una publicación puede hacer una captura, y quitar a un amigo solo afecta a lo que publiques después.';

  @override
  String get closeFriendsExplain4 =>
      'Cada amigo debe usar Mialuna con los mensajes privados activados. Otros clientes Nostr no muestran estas publicaciones.';

  @override
  String get closeFriendsExplain5 =>
      'Las publicaciones públicas siguen siendo públicas: sus archivos los ve cualquiera con el enlace.';

  @override
  String get closeFriendsExplain6 =>
      'Si ninguno de tus servidores acepta archivos cifrados, la publicación no sale: nunca en claro.';

  @override
  String get addToCloseFriends => 'Añadir a amigos cercanos';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Límite de $max amigos: $added añadidos.';
  }

  @override
  String get add => 'Añadir';

  @override
  String get signInToCreateList => 'Inicia sesión para crear tu lista.';

  @override
  String get signerNoCloseFriends =>
      'Los amigos cercanos no se pueden usar con este inicio de sesión. Inicia sesión con Amber, un bunker o la clave local.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max personas';
  }

  @override
  String get noOneYet => 'Nadie todavía.';

  @override
  String get addPeople => 'Añadir personas';

  @override
  String get friendNoPrivateMessagesWarning =>
      'No ha activado los mensajes privados: no recibirá tus publicaciones';

  @override
  String get removeFromList => 'Quitar de la lista';

  @override
  String get noOneWithThisName => 'Nadie con este nombre.';

  @override
  String get signInToSendPrivateContent =>
      'Inicia sesión para enviar contenido privado.';

  @override
  String get reasonNoPrivateMessages => 'no ha activado los mensajes privados';

  @override
  String get reasonNoRelayAnswered => 'ningún relay respondió';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get noRelayAcceptedRetry =>
      'Ningún relay lo aceptó. Inténtalo más tarde.';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get fieldName => 'Nombre';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'URL del avatar';

  @override
  String get fieldNip05 => 'NIP-05 (p. ej. you@example.com)';

  @override
  String get browsingAsGuest => 'Estás navegando como invitado';

  @override
  String get signInToInteract =>
      'Inicia sesión para publicar, seguir e interactuar.';

  @override
  String get settings => 'Ajustes';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get npubCopied => 'npub copiado';

  @override
  String get copyNpub => 'Copiar npub';

  @override
  String get mute => 'Silenciar';

  @override
  String get block => 'Bloquear';

  @override
  String get posts => 'Publicaciones';

  @override
  String get saved => 'Guardados';

  @override
  String get nothingPublishedYet => 'Aún no has publicado nada.';

  @override
  String get noPostsOnRelays => 'No hay publicaciones en los relays.';

  @override
  String get noReelsPublished => 'No hay reels publicados.';

  @override
  String get noReelsOnRelays => 'No hay reels en los relays.';

  @override
  String get noSavedPosts => 'No hay publicaciones guardadas.';

  @override
  String get followingButton => 'Siguiendo';

  @override
  String get follow => 'Seguir';

  @override
  String get messageButton => 'Mensaje';

  @override
  String get loginLocalKey => 'Clave local';

  @override
  String get loginGuest => 'Invitado';

  @override
  String get followUpdateFailed =>
      'No se han podido actualizar tus seguidos. Inténtalo de nuevo.';

  @override
  String get noReelsComeBack => 'No hay reels en los relays.\n¡Vuelve pronto!';

  @override
  String get followUpdateFailedShort =>
      'No se han podido actualizar tus seguidos';

  @override
  String get needOneReadRelay => 'Hace falta al menos un relay de lectura.';

  @override
  String get listSavedLocally =>
      'Lista guardada en este dispositivo, sin publicar.';

  @override
  String get noRelayAcceptedList =>
      'Ningún relay aceptó la lista: se reintentará más tarde.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relay list publicada en $count relays',
      one: 'Relay list publicada en 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Servidores de medios actualizados';

  @override
  String get appearance => 'Apariencia';

  @override
  String get publishingSettings => 'Publicación';

  @override
  String get addMialunaHashtag => 'Añadir #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Añade el hashtag oficial a las publicaciones y las historias públicas. Puedes quitarlo cuando quieras.';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Relays guardan y distribuyen el contenido. Inicia sesión para usar tu lista automáticamente (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'La lista se sincroniza con tu perfil de Nostr (NIP-65): cada cambio se publica y vale para todas tus aplicaciones.';

  @override
  String get syncing => 'Sincronizando…';

  @override
  String get waitingFirstSync => 'Esperando la primera sincronización';

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get addRelay => 'Añadir relay';

  @override
  String get restoreDefaultRelays => 'Restaurar los relays predeterminados';

  @override
  String get createYourList => 'Crear tu lista';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Publicaciones, historias y vídeos visibles solo para ellos, con fotos y vídeos cifrados.';

  @override
  String get mediaServersBlossom => 'Servidores de medios (Blossom)';

  @override
  String get mediaServersExplain =>
      'Las fotos y los vídeos se suben solo a estos servidores, en el orden indicado: vale el primero que los acepte. EXIF y la ubicación se quitan antes de subir.';

  @override
  String get primary => 'Principal';

  @override
  String get makePrimary => 'Hacer principal';

  @override
  String get remove => 'Quitar';

  @override
  String get addServer => 'Añadir servidor';

  @override
  String get moderation => 'Moderación';

  @override
  String get moderationExplain =>
      'Los autores silenciados y los hashtags ocultos se sincronizan con NIP-51. Los autores bloqueados se quedan solo en este dispositivo.';

  @override
  String get mutedAuthors => 'Autores silenciados';

  @override
  String get noMutedAuthors => 'No hay autores silenciados';

  @override
  String get blockedAuthors => 'Autores bloqueados';

  @override
  String get noBlockedAuthors => 'No hay autores bloqueados';

  @override
  String get hiddenHashtags => 'Hashtags ocultos';

  @override
  String get noHiddenHashtags => 'No hay hashtags ocultos';

  @override
  String get hashtagToHide => '#hashtag para ocultar';

  @override
  String get storage => 'Almacenamiento';

  @override
  String get clearCache => 'Borrar caché de eventos y borradores';

  @override
  String get cacheCleared => 'Caché borrada';

  @override
  String get reviewIntro => 'Revisar la introducción';

  @override
  String get reviewIntroSubtitle =>
      'Qué es público, qué es privado y los límites de los amigos cercanos.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'No hay monedero Lightning: dirección copiada ($address)';
  }

  @override
  String get about => 'Acerca de';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Tus momentos, bajo la misma luna.\nCódigo abierto (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Dirección no válida: usa wss://…';

  @override
  String get invalidServerAddress => 'Dirección no válida: usa https://…';

  @override
  String get relayRead => 'Lectura';

  @override
  String get relayWrite => 'Escritura';

  @override
  String get support => 'Apoyo';

  @override
  String get supportText =>
      'Mialuna es gratis, no tiene anuncios y no te rastrea. Si te gusta, puedes enviar unos sats por la red Lightning.';

  @override
  String get donateWithLightning => 'Donar con Lightning';

  @override
  String get authorNoZaps => 'Este autor no acepta zaps';

  @override
  String get sendZap => 'Enviar un zap ⚡';

  @override
  String get amountInSats => 'Importe en sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'mín. $min – máx. $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Inicia sesión para enviar zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap de $sats sats enviado ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'El pago NWC falló: $error';
  }

  @override
  String get noLightningWallet => 'No hay monedero Lightning';

  @override
  String storiesRailLabel(Object state) {
    return 'Historias, $state';
  }

  @override
  String get close => 'Cerrar';

  @override
  String hoursAgo(int hours) {
    return 'hace $hours h';
  }

  @override
  String daysAgo(int days) {
    return 'hace $days d';
  }

  @override
  String get now => 'ahora';

  @override
  String get youPrefix => 'Tú: ';

  @override
  String get storiesStateUnseen => 'nuevas';

  @override
  String get storiesStateSeen => 'vistas';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'lun',
      'tue': 'mar',
      'wed': 'mié',
      'thu': 'jue',
      'fri': 'vie',
      'sat': 'sáb',
      'sun': 'dom',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Compartió un momento';

  @override
  String get blossomOtherError => 'error';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Esta foto no se puede editar aquí.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notificaciones nuevas',
      one: '1 notificación nueva',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes sin leer',
      one: '1 mensaje sin leer',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Hecho';

  @override
  String get storyAddText => 'Añadir texto';

  @override
  String get storyEditText => 'Editar texto';

  @override
  String get storyTextHint => 'Escribe algo… los #hashtags se pueden tocar';

  @override
  String get storyTextsHelp =>
      'Toca la imagen para escribir. Arrastra para mover, pellizca para cambiar el tamaño y girar, y toca un texto para editarlo.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count textos',
      one: '1 texto',
      zero: 'Sin texto',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Clásica';

  @override
  String get storyFontBold => 'Negrita';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Cursiva';

  @override
  String get storyTextBackground => 'Fondo del texto';

  @override
  String get storyTextColor => 'Color del texto';

  @override
  String storyTextLimit(int max) {
    return 'Puedes añadir hasta $max textos.';
  }

  @override
  String get wotTitle => 'Red de confianza';

  @override
  String get wotEnable => 'La red de confianza está siempre activa';

  @override
  String wotExplain(int min) {
    return 'Siempre activa. Descubrir muestra solo esta red: tú, las personas a las que sigues y quien sea seguido por al menos $min de ellas. La misma red oculta comentarios, notificaciones, publicaciones privadas y mensajes del resto. Se calcula en este teléfono con las listas públicas de seguidos la primera vez que abres la aplicación; después se reutiliza. No se envía nada a ningún servidor.';
  }

  @override
  String get wotRefresh => 'Actualizar la red ahora';

  @override
  String get wotStatusIdle =>
      'Aún no está creada. Se crea la primera vez que abres la aplicación.';

  @override
  String get wotBuildingTitle => 'Creando tu feed de Descubrir';

  @override
  String get wotBuildingBody =>
      'Viendo a quién siguen también las personas a las que sigues, y preparando Descubrir.';

  @override
  String get wotDiscoverHint =>
      'Solo tu red de confianza: gente a la que sigues y gente a la que siguen bastantes de ellas.';

  @override
  String get wotDiscoverSignIn =>
      'Descubrir muestra tu red de confianza. Inicia sesión y, la primera vez, Mialuna lee a quién sigues y crea este feed. Después lo reutiliza.';

  @override
  String get wotDiscoverEmpty =>
      'Aún no hay publicaciones de tu red de confianza.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Viendo a quién siguen tus seguidos… $done de $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Tu red: $direct personas a las que sigues y $indirect seguidas por bastantes de ellas. Actualizada $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'No se pudo calcular tu red: $reason';
  }

  @override
  String get wotNoFollows => 'aún no sigues a nadie';

  @override
  String get messageRequests => 'Solicitudes de mensaje';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversaciones fuera de tu red de confianza',
      one: '1 conversación fuera de tu red de confianza',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'De gente fuera de tu red de confianza. No cuentan como no leídas. Responde para pasar una conversación a tu bandeja.';

  @override
  String get storyViewsSetting => 'Dejar ver que miré sus historias';

  @override
  String get storyViewsSettingExplain =>
      'Cuando ves una historia, se envía un acuse al autor, cifrado para que solo esa persona pueda leerlo. Pone tu nombre junto al suyo; los relays no ven nada. Si no se puede entregar, se guarda y se reintenta más tarde. Desactívalo para ver sin avisar a nadie: los acuses aún no enviados se descartan (uno ya entregado no se puede retirar).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vista por $count personas',
      one: 'Vista por 1 persona',
      zero: 'Aún sin visitas',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Nadie ha visto esta historia todavía, o sus acuses no te han llegado.';

  @override
  String get storyViewsHint =>
      'Solo quien lo permite envía un acuse, así que el número real puede ser mayor.';

  @override
  String get systemNotifications => 'Notificaciones del sistema';

  @override
  String get systemNotificationsExplain =>
      'Muestra una notificación en tu teléfono cuando llega algo nuevo y Mialuna está en segundo plano. Los mensajes privados no muestran el texto, ni en la pantalla de bloqueo. Android pausa las aplicaciones que pasan mucho en segundo plano, así que las notificaciones llegan mientras Mialuna sigue abierta.';

  @override
  String get systemNotificationsBlocked =>
      'Las notificaciones de Mialuna están desactivadas en los ajustes del teléfono.';

  @override
  String get systemNotificationsOpenSettings => 'Abrir ajustes';

  @override
  String get systemNotificationsBattery =>
      'Android duerme las aplicaciones unos minutos después de apagar la pantalla, y con ellas paran las notificaciones. Para seguir recibiéndolas, pon el uso de batería de Mialuna en “Sin restricciones”.';

  @override
  String get systemNotificationsBatteryAction => 'Abrir ajustes de batería';

  @override
  String get newFollowersSetting => 'Mostrar nuevos seguidores';

  @override
  String get newFollowersSettingExplain =>
      'Los nuevos seguidores salen en Notificaciones y en tu teléfono. Desactívalo si te inundan de seguimientos: los me gusta, los comentarios y los zaps siguen saliendo.';

  @override
  String get systemNotificationMessage => 'te envió un mensaje privado';

  @override
  String get systemNotificationNewMessage => 'Nuevo mensaje privado';

  @override
  String get systemNotificationNew => 'Nueva notificación';

  @override
  String get notificationChannelSocial =>
      'Reacciones, comentarios, zaps y seguidores';

  @override
  String get notificationChannelMessages => 'Mensajes privados';

  @override
  String get zapInvoiceMismatch =>
      'La factura no coincide con el importe que elegiste. No se ha pagado nada.';

  @override
  String get storyYourStory => 'Tu historia';

  @override
  String get storyNew => 'Nueva historia';

  @override
  String get storyAddSemantics => 'Añadir a tu historia';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count historias',
      one: '1 historia',
    );
    return 'Tu historia, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Tamaño del texto';

  @override
  String get storyPickPrompt => 'Elige una foto o un vídeo para tu historia';

  @override
  String get storyEditPhoto => 'Editar foto';

  @override
  String get storyCaption => 'Pie';

  @override
  String get storyDiscardTitle => '¿Descartar esta historia?';

  @override
  String get storyDiscard => 'Descartar';

  @override
  String get storyShare => 'Compartir';

  @override
  String get storyShared => 'Historia compartida';

  @override
  String get deletePost => 'Eliminar';

  @override
  String get deletePostTitle => '¿Eliminar esta publicación?';

  @override
  String get deleteStoryTitle => '¿Eliminar esta historia?';

  @override
  String get deletePostBody =>
      'Mialuna pedirá a tus relays que la eliminen y a los servidores de medios que borren sus fotos o su vídeo. Un relay que ignore la petición, o quien ya haya guardado una copia, puede seguir teniéndola.';

  @override
  String get deletePrivateBody =>
      'Una publicación de amigos cercanos no se puede retirar de los relays. Mialuna pedirá a las aplicaciones de tus amigos que la quiten y al servidor de medios que borre sus archivos cifrados. Un amigo que ya haya guardado una copia puede seguir teniéndola.';

  @override
  String get deletingPost => 'Eliminando…';

  @override
  String get postDeleted => 'Eliminada.';

  @override
  String get postWasDeleted => 'Esta publicación se ha eliminado.';

  @override
  String get deleteNotAllowed =>
      'Solo puede eliminarla la cuenta que la publicó.';

  @override
  String deleteFailed(Object reason) {
    return 'No se pudo eliminar: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Ningún relay aceptó la petición de borrado, así que sigue en línea. Comprueba la conexión e inténtalo de nuevo.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'No se pudo quitar el contenido de $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Tu firmante no autorizó quitar el contenido, así que los archivos siguen en el servidor de medios.';

  @override
  String deleteFriendsMissed(Object count) {
    return 'No se pudo avisar a $count de tus amigos cercanos, así que puede seguir en sus teléfonos.';
  }

  @override
  String get storyCleanupSetting => 'Eliminar mis historias al caducar';

  @override
  String get storyCleanupSettingExplain =>
      'A las 24 horas, Mialuna pide a tus relays y a tus servidores de medios que eliminen tus historias, fotos y vídeos incluidos. Un servidor que ignore la petición, o quien haya guardado una copia, puede seguir teniéndolas.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Tu firmante tiene que aprobar cada limpieza, así que espera a que lo pidas. Historias caducadas en espera: $count.';
  }

  @override
  String get storyCleanupNow => 'Eliminar ahora';

  @override
  String get storyCleanupDone => 'Historias caducadas eliminadas.';

  @override
  String get storyCleanupPartly =>
      'Algunas aún no se pudieron eliminar; Mialuna lo intentará de nuevo.';
}
