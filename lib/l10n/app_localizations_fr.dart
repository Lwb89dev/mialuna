// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get syncUpToDate => 'À jour';

  @override
  String get syncFailed => 'Échec de la synchro';

  @override
  String get relaysUpdatedFromProfile =>
      'Relays mis à jour depuis ton profil (NIP-65)';

  @override
  String get relayListPublished => 'Liste Relay publiée';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Serveurs médias mis à jour depuis ton profil';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Découvrir';

  @override
  String get tabCreate => 'Créer';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Profil';

  @override
  String get signInToUploadMedia => 'Connecte-toi pour envoyer un média.';

  @override
  String get noMediaServer =>
      'Aucun serveur média configuré. Ajoutes-en un dans Réglages.';

  @override
  String serverNoResponse(Object server) {
    return '$server : aucune réponse';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server : injoignable ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Envoi refusé — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Aucun serveur n\'a accepté le fichier — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'réponse invalide';

  @override
  String get blossomInvalidFileUrl => 'adresse de fichier invalide';

  @override
  String get blossomServerAlteredFile => 'le serveur a modifié le fichier';

  @override
  String get blossomBadRequest => 'requête invalide';

  @override
  String get blossomUnauthorized => 'autorisation refusée';

  @override
  String get blossomPaymentRequired => 'paiement requis';

  @override
  String get blossomForbidden => 'non autorisé';

  @override
  String get blossomLengthRequired => 'taille manquante';

  @override
  String get blossomTooLarge => 'fichier trop volumineux';

  @override
  String get blossomUnsupportedType => 'format non accepté';

  @override
  String get blossomTooManyRequests => 'trop de requêtes';

  @override
  String get blossomServerError => 'erreur serveur';

  @override
  String get cipherInvalidKey => 'Clé invalide';

  @override
  String get cipherTruncated => 'Fichier chiffré tronqué';

  @override
  String get cipherMismatch =>
      'Le fichier ne correspond pas à la clé : modifié ou corrompu';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Format HEIC/AVIF : la conversion exige sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'La vidéo WebM/MKV n\'est pas prise en charge : utilise MP4 ou MOV pour retirer les métadonnées avant l\'envoi.';

  @override
  String get sanitizeUnknownFormat =>
      'Format non reconnu : photos JPEG/PNG/WebP/GIF ou vidéos MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Impossible de retirer toutes les métadonnées ($items) : fichier non envoyé.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Impossible de traiter le fichier : $error';
  }

  @override
  String get sanitizeJpegInvalid => 'JPEG invalide';

  @override
  String get sanitizeJpegTruncated => 'JPEG tronqué';

  @override
  String get sanitizeJpegNoSize => 'JPEG sans dimensions';

  @override
  String get sanitizeJpegUndecodable => 'JPEG impossible à décoder';

  @override
  String get sanitizePngTruncated => 'PNG tronqué';

  @override
  String get sanitizePngInvalid => 'PNG invalide';

  @override
  String get sanitizeGifInvalid => 'GIF invalide';

  @override
  String get sanitizeGifTruncated => 'GIF tronqué';

  @override
  String get sanitizeWebpTruncated => 'WebP tronqué';

  @override
  String get sanitizeWebpInvalid => 'WebP invalide';

  @override
  String get sanitizeMp4Invalid => 'Vidéo MP4/MOV invalide';

  @override
  String get sanitizeConversionFailed => 'Échec de la conversion';

  @override
  String get sanitizeHeifUnsupported =>
      'Ce format (HEIC/AVIF) ne peut pas être converti sur cet appareil. Choisis une photo JPEG ou PNG.';

  @override
  String get privateMediaNotEncrypted => 'Le média n\'est pas chiffré';

  @override
  String serverReplied(Object status) {
    return 'Le serveur a répondu $status';
  }

  @override
  String get fileTooLarge => 'Fichier trop volumineux';

  @override
  String get serverFileNotOriginal =>
      'Le fichier sur le serveur n\'est pas l\'original';

  @override
  String get contentMismatch => 'Le contenu ne correspond pas';

  @override
  String get mediaUnreachable => 'Média injoignable';

  @override
  String get amberInvalidKey => 'Amber a renvoyé une clé invalide';

  @override
  String get amberNoKey => 'Amber n\'a pas renvoyé de clé';

  @override
  String get amberRequestRejected => 'Requête refusée dans Amber';

  @override
  String get amberAndroidOnly => 'Amber n\'est disponible que sur Android';

  @override
  String get amberEmptySignature => 'Amber a renvoyé une signature vide';

  @override
  String get amberSignRejected => 'Signature refusée dans Amber';

  @override
  String get amberTimeout => 'Amber n\'a pas répondu à temps';

  @override
  String get amberEmptyResponse => 'Amber a renvoyé une réponse vide';

  @override
  String get bunkerInvalidUrl => 'URL bunker invalide';

  @override
  String get bunkerNoRelay => 'Le bunker n\'indique aucun relay';

  @override
  String get bunkerWebAuth =>
      'Le bunker exige une autorisation web (auth_url n\'est pas pris en charge)';

  @override
  String get bunkerInvalidKey => 'Le bunker n\'a pas renvoyé de clé valide';

  @override
  String get signerInvalidResponse =>
      'Le signataire a renvoyé un événement signé invalide';

  @override
  String get bunkerTimeout => 'Délai du bunker dépassé';

  @override
  String get nwcInvalidUri => 'URI NWC invalide';

  @override
  String get nwcNoRelay => 'L\'URI NWC n\'indique aucun relay';

  @override
  String get nwcNoSecret => 'L\'URI NWC ne contient pas de secret valide';

  @override
  String get nwcTimeout => 'Délai du portefeuille dépassé';

  @override
  String get signerNoPrivateMessages =>
      'Cette connexion ne gère pas les messages privés';

  @override
  String get zapNotSupported => 'Cette adresse ne gère pas les zaps Nostr';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Montant hors limites ($min–$max sats)';
  }

  @override
  String get commentNotSent => 'Commentaire non envoyé. Réessaie plus tard.';

  @override
  String get comments => 'Commentaires';

  @override
  String get noCommentsYet => 'Pas encore de commentaires.';

  @override
  String get signInToComment => 'Connecte-toi pour commenter.';

  @override
  String get addComment => 'Ajouter un commentaire…';

  @override
  String get signInToPublish => 'Connecte-toi pour publier.';

  @override
  String get addMediaFirst =>
      'Ajoute au moins une photo ou une vidéo avant de publier.';

  @override
  String get removingMetadata => 'Suppression des métadonnées…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Envoi $current sur $total…';
  }

  @override
  String get creatingPreview => 'Création de l\'aperçu…';

  @override
  String uploadFailed(Object error) {
    return 'Échec de l\'envoi : $error';
  }

  @override
  String get publishing => 'Publication…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Aucun relay n\'a accepté la publication$reason. Le contenu reste dans tes brouillons.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Cette connexion ne gère pas le contenu privé. Utilise Amber, un bunker ou la clé locale.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Ta liste d\'amis proches est vide : ajoute quelqu\'un.';

  @override
  String get fileOver100Mb =>
      'Le fichier dépasse 100 Mo : c\'est la limite pour les amis proches (il est chiffré en entier sur ton téléphone).';

  @override
  String get encryptingOnPhone => 'Chiffrement sur ton téléphone…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Aucun de tes serveurs médias n\'a accepté le fichier chiffré. Il n\'est pas publié en clair. Ajoute dans Réglages un serveur qui accepte les fichiers chiffrés (par exemple cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Envoi aux amis…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Envoi aux amis $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Aucun ami n\'a reçu la publication$reason. Le contenu reste dans tes brouillons.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Envoyé à $count amis proches 🔒',
      one: 'Envoyé à 1 ami proche 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Envoyé à $delivered amis.',
      one: 'Envoyé à 1 ami.',
    );
    return '$_temp0 $missed ne l\'ont pas reçu (messages privés désactivés).';
  }

  @override
  String get altText => 'Texte alternatif';

  @override
  String get altTextHint => 'Décris le contenu pour qui ne peut pas le voir…';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get momentPublished => 'Moment publié ✨';

  @override
  String get newMoment => 'Nouveau moment';

  @override
  String get publish => 'Publier';

  @override
  String get guestMode => 'Mode invité';

  @override
  String get signInToPostMoments => 'Connecte-toi pour publier tes moments.';

  @override
  String get signIn => 'Se connecter';

  @override
  String get kindPhoto => 'Photo';

  @override
  String get kindVideo => 'Vidéo';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'story';

  @override
  String get storyExpiryNote =>
      'Les stories expirent après 24 heures sur les relays qui respectent NIP-40, mais d\'autres peuvent encore les enregistrer ou les archiver.';

  @override
  String get fromGallery => 'Depuis la galerie';

  @override
  String get galleryLongPressVideo => 'Galerie (appui long pour une vidéo)';

  @override
  String get addVideo => 'Ajouter une vidéo';

  @override
  String get camera => 'Appareil photo';

  @override
  String get exifRemovedNote =>
      'Les métadonnées de lieu (EXIF) sont retirées automatiquement.';

  @override
  String get writeCaption => 'Écris une légende…';

  @override
  String get privatePostNote =>
      'Publication privée : pas de hashtags publics, introuvable par la recherche.';

  @override
  String willPublishAs(Object caption) {
    return 'Sera publié ainsi : \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Touche une miniature pour ajouter un texte alternatif.';

  @override
  String get sensitiveContent => 'Contenu sensible';

  @override
  String get sensitiveContentNote =>
      'La publication sera masquée derrière un avertissement (NIP-36).';

  @override
  String get uploadingMedia => 'Envoi des médias…';

  @override
  String get audiencePublic => 'Public';

  @override
  String get closeFriends => 'Amis proches';

  @override
  String get signerCannotPublishCloseFriends =>
      'Avec cette connexion tu ne peux pas publier pour les amis proches : utilise Amber, un bunker ou la clé locale.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Ta liste est vide : ajoute les personnes qui peuvent voir cette publication.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Seuls tes $count amis proches verront ceci. Les photos et vidéos sont chiffrées sur ton téléphone avant l\'envoi.',
      one: 'Seul ton 1 ami proche verra ceci. Les photos et vidéos sont chiffrées sur ton téléphone avant l\'envoi.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Ajouter des amis';

  @override
  String get manageList => 'Gérer la liste';

  @override
  String get edit => 'Modifier';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get apply => 'Appliquer';

  @override
  String get cropFree => 'Libre';

  @override
  String get cropOriginal => 'Original';

  @override
  String get rotate => 'Pivoter';

  @override
  String get flip => 'Miroir';

  @override
  String get brightness => 'Luminosité';

  @override
  String get contrast => 'Contraste';

  @override
  String get saturation => 'Saturation';

  @override
  String postsByAuthor(Object author) {
    return 'Publications de $author…';
  }

  @override
  String get searchHint => 'Chercher des gens, hashtags ou mots…';

  @override
  String get clear => 'Effacer';

  @override
  String get recent => 'Récents';

  @override
  String get searchDependsOnRelays =>
      'La recherche dépend des relays configurés : les résultats peuvent être partiels.';

  @override
  String get recentPostsEverywhere =>
      'Publications récentes de tout le réseau, y compris de gens que tu ne suis pas.';

  @override
  String get noResultsOnRelays => 'Aucun résultat sur les relays configurés.';

  @override
  String get noRecentPostsFromFollowed =>
      'Aucune publication récente des personnes que tu suis.';

  @override
  String get noMomentsFound =>
      'Aucun moment trouvé sur les relays. Vérifie ta connexion.';

  @override
  String get loadFailed => 'Échec du chargement';

  @override
  String get notifications => 'Notifications';

  @override
  String get messages => 'Messages';

  @override
  String get homeEmptyFollowsNobody =>
      'Les publications des personnes que tu suis apparaissent ici.\nTu ne suis encore personne : découvre des gens et des profils intéressants.';

  @override
  String get discoverPeople => 'Découvrir des gens';

  @override
  String get homeEmpty =>
      'Pas encore de moments.\nTire vers le bas pour actualiser ou publie ta première photo.';

  @override
  String get retry => 'Réessayer';

  @override
  String get seenEverything => 'Tu as tout vu pour le moment ✨';

  @override
  String get discoverMoreProfiles => 'Découvrir d\'autres profils';

  @override
  String get feedFollowing => 'Suivis';

  @override
  String get signInToSeeFollowed =>
      'Connecte-toi pour voir les publications des personnes que tu suis';

  @override
  String get videoPreview => 'Aperçu vidéo';

  @override
  String get cannotOpenPrivateVideo => 'Impossible d\'ouvrir la vidéo privée';

  @override
  String get cannotPlayVideo => 'Impossible de lire la vidéo';

  @override
  String get pauseVideo => 'Mettre la vidéo en pause';

  @override
  String get playVideo => 'Lire la vidéo';

  @override
  String errorTapToRetry(Object error) {
    return '$error — touche pour réessayer';
  }

  @override
  String get soundOn => 'Activer le son';

  @override
  String get soundOff => 'Couper le son';

  @override
  String get postImage => 'Image de la publication';

  @override
  String get imageUnavailable => 'Image indisponible';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nTouche pour réessayer';
  }

  @override
  String get cannotOpenPrivateContent =>
      'Impossible d\'ouvrir ce contenu privé';

  @override
  String get privateImage => 'Image privée';

  @override
  String get invalidImage => 'Image invalide';

  @override
  String get more => 'Plus';

  @override
  String get removeFromSaved => 'Retirer des enregistrés';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get muteAuthor => 'Masquer l\'auteur';

  @override
  String get blockAuthor => 'Bloquer l\'auteur';

  @override
  String get report => 'Signaler';

  @override
  String get like => 'J\'aime';

  @override
  String get sendInMessage => 'Envoyer dans un message';

  @override
  String get zapOptional => 'Zap (facultatif)';

  @override
  String get closeFriendsOnlyNote =>
      'Visible seulement par les amis proches. Les j\'aime et les réponses vont seulement à l\'auteur.';

  @override
  String get likeFailed => 'Impossible d\'envoyer le j\'aime';

  @override
  String get nostrLinkCopied => 'Lien Nostr copié dans le presse-papiers';

  @override
  String get authorMuted => 'Auteur masqué';

  @override
  String get authorBlocked => 'Auteur bloqué';

  @override
  String get reportSent => 'Signalement envoyé (NIP-56)';

  @override
  String get signInToReport => 'Connecte-toi pour signaler';

  @override
  String minutesAgo(Object minutes) {
    return 'il y a $minutes min';
  }

  @override
  String get show => 'Afficher';

  @override
  String get chatEmptyHint =>
      'Écris le premier message.\nIl est chiffré : vous deux seuls pouvez le voir.';

  @override
  String get messageHint => 'Message…';

  @override
  String get send => 'Envoyer';

  @override
  String get notSentSuffix => ' non envoyé';

  @override
  String get contentUnavailable =>
      'Contenu indisponible (expiré ou introuvable sur les relays)';

  @override
  String get signInToSendPrivateMessages =>
      'Connecte-toi pour envoyer des messages privés.';

  @override
  String get cannotMessageYourself => 'Tu ne peux pas t\'écrire à toi-même.';

  @override
  String get recipientNoPrivateMessages =>
      'Cette personne n\'a pas encore activé les messages privés.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Aucun relay du destinataire n\'a accepté le message$reason.';
  }

  @override
  String sendFailed(Object error) {
    return 'Échec de l\'envoi : $error';
  }

  @override
  String get signInToReadMessages =>
      'Connecte-toi pour lire et envoyer des messages privés.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Les messages privés sont indisponibles avec cette connexion. Connecte-toi avec Amber, un bunker ou la clé locale.';

  @override
  String get inboxEmpty =>
      'Aucune conversation.\nTouche le crayon pour écrire à quelqu\'un, ou transfère un moment avec l\'icône ✈ sous chaque publication.';

  @override
  String get newMessage => 'Nouveau message';

  @override
  String get privateMessagesEnabled => 'Messages privés activés';

  @override
  String get enableMessagesFailed => 'Impossible de les activer. Réessaie.';

  @override
  String get enablePrivateMessages => 'Activer les messages privés';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Pour recevoir des messages, indique sur quels relays ils doivent arriver. Une petite liste (NIP-17) est publiée avec $count relays par défaut : tu pourras la changer plus tard. Les messages restent chiffrés : les relays ne voient ni qui écrit ni le texte.';
  }

  @override
  String get turnOn => 'Activer';

  @override
  String get searchByNameOrUsername => 'Chercher par nom ou pseudo';

  @override
  String get searching => 'Recherche…';

  @override
  String get noOneWithNameHint =>
      'Personne avec ce nom. Essaie moins de lettres ou une adresse comme nom@domaine.com.';

  @override
  String get sent => 'Envoyé';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Envoyé à $count personnes',
      one: 'Envoyé à 1 personne',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Envoyé à $count personnes. $failure',
      one: 'Envoyé à 1 personne. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Tu ne peux pas utiliser les messages privés avec cette connexion.';

  @override
  String get followToStartOrSearch =>
      'Suis quelqu\'un pour commencer, ou cherche par nom.';

  @override
  String get addMessage => 'Ajouter un message…';

  @override
  String sendWithCount(Object count) {
    return 'Envoyer ($count)';
  }

  @override
  String get linkCopied => 'Lien copié dans le presse-papiers';

  @override
  String get noNotifications => 'Aucune notification pour le moment.';

  @override
  String get notificationsDependOnRelays =>
      'Les notifications dépendent des relays : elles peuvent être incomplètes.';

  @override
  String get reactedToYourMoment => 'a réagi à ton moment';

  @override
  String commentedText(Object text) {
    return 'a commenté : $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 't\'a envoyé $sats sats$comment';
  }

  @override
  String get sentYouZap => 't\'a envoyé un zap';

  @override
  String get startedFollowingYou => 'a commencé à te suivre';

  @override
  String get amberNotFound => 'Amber introuvable';

  @override
  String get amberExplain =>
      'Amber est un signataire Nostr qui garde ta clé privée hors de Mialuna. Installe-le et réessaie.';

  @override
  String get downloadFromFdroid => 'Télécharger sur F-Droid';

  @override
  String get continueWithAmber => 'Continuer avec Amber';

  @override
  String get amberRecommended =>
      'Recommandé : ta clé privée reste en sécurité dans Amber.';

  @override
  String get amberNotDetected =>
      'Amber non détecté : installe-le pour la connexion recommandée.';

  @override
  String get exploreWithoutAccount => 'Explorer sans compte';

  @override
  String get remoteBunker => 'bunker distant (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'URL bunker invalide.';

  @override
  String get connectBunker => 'Connecter le bunker';

  @override
  String get advancedNsec => 'Connexion avancée (nsec)';

  @override
  String get nsecWarning =>
      'Attention : coller ta clé privée est risqué. Ne la partage jamais. Sur Android, préfère Amber.';

  @override
  String get invalidNsec => 'Clé nsec invalide.';

  @override
  String get signInWithNsec => 'Se connecter avec nsec';

  @override
  String get tagline => 'Tes moments, sous la même lune.';

  @override
  String get skip => 'Passer';

  @override
  String get permissionsAndWallet => 'Autorisations et portefeuille';

  @override
  String get permissionsExplain =>
      'Elles servent seulement à publier et à recevoir des notifications. Tu peux les modifier à tout moment dans les réglages du système.';

  @override
  String get photosAndVideos => 'Photos et vidéos';

  @override
  String get toUploadYourMoments => 'Pour envoyer tes moments';

  @override
  String get allow => 'Autoriser';

  @override
  String get reactionsCommentsZaps => 'Réactions, commentaires et zaps';

  @override
  String get lightningWalletOptional => 'Portefeuille Lightning (facultatif)';

  @override
  String get nwcExplain =>
      'Connecte un portefeuille Nostr Wallet Connect pour envoyer des zaps sans quitter l\'app.';

  @override
  String get walletConnected => 'Portefeuille connecté';

  @override
  String get disconnect => 'Déconnecter';

  @override
  String get connectWallet => 'Connecter le portefeuille';

  @override
  String get getStarted => 'Commencer';

  @override
  String get welcome1 =>
      'Mialuna est un réseau social visuel : photos, vidéos, Reels et stories — jamais de publications seulement texte.';

  @override
  String get welcome2 =>
      'Il repose sur Nostr, un protocole ouvert : ton identité est une clé que tu possèdes, pas un compte qu\'une entreprise peut supprimer. Pas de pubs, pas de traqueurs, pas de serveurs centraux.';

  @override
  String get welcome3 =>
      'Partage ta lumière avec des gens partout, depuis n\'importe quelle app qui parle le même langage ouvert.';

  @override
  String onboardingWot(int min) {
    return 'Le réseau de confiance est toujours actif. La première fois que tu ouvres Mialuna, il lit qui tu suis et construit le fil Découvrir à partir de ce réseau : toi, les personnes que tu suis, et celles qu\'au moins $min d\'entre elles suivent. Les fois suivantes, ce fil est déjà là.';
  }

  @override
  String get publicAndPrivate => 'Public et privé';

  @override
  String get publicAndPrivateIntro =>
      'Mialuna repose sur Nostr, un réseau ouvert. Ce que tu publies est public : publications, photos et vidéos restent visibles pour quiconque a le lien, même hors de Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Seules les personnes de cette liste reçoivent tes publications, stories et vidéos « Amis proches ». La liste est dans la publication ; tu n\'as pas à la choisir à chaque fois.';

  @override
  String get closeFriendsExplain2 =>
      'Les photos et vidéos sont chiffrées sur ton téléphone avant l\'envoi. Les serveurs de fichiers (Blossom) ne chiffrent rien eux-mêmes : c\'est pour ça que Mialuna le fait, et le serveur ne voit que des données illisibles. Qui trouve l\'adresse du fichier ne peut pas l\'ouvrir.';

  @override
  String get closeFriendsExplain3 =>
      'Ce n\'est pas une garantie absolue : qui reçoit une publication peut faire une capture d\'écran, et retirer un ami ne vaut que pour les publications futures.';

  @override
  String get closeFriendsExplain4 =>
      'Chaque ami doit utiliser Mialuna avec les messages privés activés. Les autres clients Nostr n\'affichent pas ces publications.';

  @override
  String get closeFriendsExplain5 =>
      'Les publications publiques restent publiques : leurs fichiers sont visibles pour quiconque a le lien.';

  @override
  String get closeFriendsExplain6 =>
      'Si aucun de tes serveurs n\'accepte les fichiers chiffrés, la publication n\'est pas publiée : jamais en clair.';

  @override
  String get addToCloseFriends => 'Ajouter aux amis proches';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Limite de $max amis : $added ajoutés.';
  }

  @override
  String get add => 'Ajouter';

  @override
  String get signInToCreateList => 'Connecte-toi pour créer ta liste.';

  @override
  String get signerNoCloseFriends =>
      'Les amis proches sont indisponibles avec cette connexion. Connecte-toi avec Amber, un bunker ou la clé locale.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max personnes';
  }

  @override
  String get noOneYet => 'Personne pour le moment.';

  @override
  String get addPeople => 'Ajouter des personnes';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Messages privés non activés : cette personne ne recevra pas tes publications';

  @override
  String get removeFromList => 'Retirer de la liste';

  @override
  String get noOneWithThisName => 'Personne avec ce nom.';

  @override
  String get signInToSendPrivateContent =>
      'Connecte-toi pour envoyer du contenu privé.';

  @override
  String get reasonNoPrivateMessages => 'n\'a pas activé les messages privés';

  @override
  String get reasonNoRelayAnswered => 'aucun relay n\'a répondu';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get noRelayAcceptedRetry =>
      'Aucun relay ne l\'a accepté. Réessaie plus tard.';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get fieldName => 'Nom';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'URL de l\'avatar';

  @override
  String get fieldNip05 => 'NIP-05 (p. ex. toi@exemple.com)';

  @override
  String get browsingAsGuest => 'Tu navigues en tant qu\'invité';

  @override
  String get signInToInteract =>
      'Connecte-toi pour publier, suivre et interagir.';

  @override
  String get settings => 'Réglages';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get npubCopied => 'npub copié';

  @override
  String get copyNpub => 'Copier le npub';

  @override
  String get mute => 'Masquer';

  @override
  String get block => 'Bloquer';

  @override
  String get posts => 'Publications';

  @override
  String get saved => 'Enregistrés';

  @override
  String get nothingPublishedYet => 'Tu n\'as encore rien publié.';

  @override
  String get noPostsOnRelays => 'Aucune publication trouvée sur les relays.';

  @override
  String get noReelsPublished => 'Aucun reel publié.';

  @override
  String get noReelsOnRelays => 'Aucun reel trouvé sur les relays.';

  @override
  String get noSavedPosts => 'Aucune publication enregistrée.';

  @override
  String get followingButton => 'Suivi';

  @override
  String get follow => 'Suivre';

  @override
  String get messageButton => 'Message';

  @override
  String get loginLocalKey => 'Clé locale';

  @override
  String get loginGuest => 'Invité';

  @override
  String get followUpdateFailed =>
      'Impossible de mettre à jour tes suivis pour le moment. Réessaie.';

  @override
  String get noReelsComeBack =>
      'Aucun reel trouvé sur les relays.\nReviens bientôt !';

  @override
  String get followUpdateFailedShort =>
      'Impossible de mettre à jour tes suivis pour le moment';

  @override
  String get needOneReadRelay => 'Au moins un relay en lecture est requis.';

  @override
  String get listSavedLocally =>
      'Liste enregistrée sur cet appareil, non publiée.';

  @override
  String get noRelayAcceptedList =>
      'Aucun relay n\'a accepté la liste : nouvel essai plus tard.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Liste Relay publiée vers $count relays',
      one: 'Liste Relay publiée vers 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Serveurs médias mis à jour';

  @override
  String get appearance => 'Apparence';

  @override
  String get publishingSettings => 'Publication';

  @override
  String get addMialunaHashtag => 'Ajouter #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Ajoute le hashtag officiel aux publications et stories publiques. Tu peux le désactiver à tout moment.';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Les Relays stockent et distribuent le contenu. Connecte-toi pour utiliser automatiquement ta propre liste (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'La liste est synchronisée avec ton profil Nostr (NIP-65) : chaque changement est publié et s\'applique à toutes tes apps.';

  @override
  String get syncing => 'Synchronisation…';

  @override
  String get waitingFirstSync => 'En attente de la première synchro';

  @override
  String get syncNow => 'Synchroniser';

  @override
  String get addRelay => 'Ajouter un relay';

  @override
  String get restoreDefaultRelays => 'Rétablir les relays par défaut';

  @override
  String get createYourList => 'Créer ta liste';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Publications, stories et vidéos visibles seulement par eux, avec photos et vidéos chiffrées.';

  @override
  String get mediaServersBlossom => 'Serveurs médias (Blossom)';

  @override
  String get mediaServersExplain =>
      'Les photos et vidéos ne sont envoyées qu\'à ces serveurs, dans l\'ordre affiché : le premier qui les accepte l\'emporte. EXIF et lieu sont retirés avant l\'envoi.';

  @override
  String get primary => 'Principal';

  @override
  String get makePrimary => 'Définir comme principal';

  @override
  String get remove => 'Retirer';

  @override
  String get addServer => 'Ajouter un serveur';

  @override
  String get moderation => 'Modération';

  @override
  String get moderationExplain =>
      'Les auteurs masqués et les hashtags cachés sont synchronisés via NIP-51. Les auteurs bloqués restent seulement sur cet appareil.';

  @override
  String get mutedAuthors => 'Auteurs masqués';

  @override
  String get noMutedAuthors => 'Aucun auteur masqué';

  @override
  String get blockedAuthors => 'Auteurs bloqués';

  @override
  String get noBlockedAuthors => 'Aucun auteur bloqué';

  @override
  String get hiddenHashtags => 'Hashtags cachés';

  @override
  String get noHiddenHashtags => 'Aucun hashtag caché';

  @override
  String get hashtagToHide => '#hashtag à cacher';

  @override
  String get storage => 'Stockage';

  @override
  String get clearCache => 'Vider le cache d\'événements et les brouillons';

  @override
  String get cacheCleared => 'Cache vidé';

  @override
  String get reviewIntro => 'Revoir l\'introduction';

  @override
  String get reviewIntroSubtitle =>
      'Ce qui est public, ce qui est privé, et les limites des amis proches.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Aucun portefeuille Lightning trouvé : adresse copiée ($address)';
  }

  @override
  String get about => 'À propos';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Tes moments, sous la même lune.\nCode ouvert (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress => 'Adresse invalide : utilise wss://…';

  @override
  String get invalidServerAddress => 'Adresse invalide : utilise https://…';

  @override
  String get relayRead => 'Lecture';

  @override
  String get relayWrite => 'Écriture';

  @override
  String get support => 'Soutenir';

  @override
  String get supportText =>
      'Mialuna est gratuit, sans pub, et ne te trace pas. S\'il te plaît, tu peux envoyer quelques sats via le Lightning Network.';

  @override
  String get donateWithLightning => 'Donner avec Lightning';

  @override
  String get authorNoZaps => 'Cet auteur n\'accepte pas les zaps';

  @override
  String get sendZap => 'Envoyer un zap ⚡';

  @override
  String get amountInSats => 'Montant en sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'min $min – max $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Connecte-toi pour envoyer des zaps';

  @override
  String zapSent(Object sats) {
    return 'Zap de $sats sats envoyé ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'Paiement NWC échoué : $error';
  }

  @override
  String get noLightningWallet => 'Aucun portefeuille Lightning trouvé';

  @override
  String storiesRailLabel(Object state) {
    return 'Stories, $state';
  }

  @override
  String get close => 'Fermer';

  @override
  String hoursAgo(int hours) {
    return 'il y a $hours h';
  }

  @override
  String daysAgo(int days) {
    return 'il y a $days j';
  }

  @override
  String get now => 'maintenant';

  @override
  String get youPrefix => 'Toi : ';

  @override
  String get storiesStateUnseen => 'nouveau';

  @override
  String get storiesStateSeen => 'vu';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Lun',
      'tue': 'Mar',
      'wed': 'Mer',
      'thu': 'Jeu',
      'fri': 'Ven',
      'sat': 'Sam',
      'sun': 'Dim',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'A partagé un moment';

  @override
  String get blossomOtherError => 'erreur';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Cette photo ne peut pas être modifiée ici.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouvelles notifications',
      one: '1 nouvelle notification',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages non lus',
      one: '1 message non lu',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Terminé';

  @override
  String get storyAddText => 'Ajouter du texte';

  @override
  String get storyEditText => 'Modifier le texte';

  @override
  String get storyTextHint =>
      'Écris quelque chose… les #hashtags sont touchables';

  @override
  String get storyTextsHelp =>
      'Touche l\'image pour écrire. Glisse pour déplacer, pince pour redimensionner et pivoter, touche un texte pour le modifier.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count textes',
      one: '1 texte',
      zero: 'Aucun texte',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Classique';

  @override
  String get storyFontBold => 'Gras';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Italique';

  @override
  String get storyTextBackground => 'Fond du texte';

  @override
  String get storyTextColor => 'Couleur du texte';

  @override
  String storyTextLimit(int max) {
    return 'Tu peux ajouter jusqu\'à $max textes.';
  }

  @override
  String get wotTitle => 'Réseau de confiance';

  @override
  String get wotEnable => 'Le réseau de confiance est toujours actif';

  @override
  String wotExplain(int min) {
    return 'Toujours actif. Découvrir n\'affiche que ce réseau : toi, les personnes que tu suis, et celles suivies par au moins $min d\'entre elles. Le même réseau masque commentaires, notifications, publications privées et messages de tous les autres. Il est calculé sur ce téléphone à partir des listes de suivi publiques la première fois que tu ouvres l\'app ; ensuite il est réutilisé. Rien n\'est envoyé à un serveur.';
  }

  @override
  String get wotRefresh => 'Actualiser le réseau';

  @override
  String get wotStatusIdle =>
      'Pas encore construit. Il l\'est la première fois que tu ouvres l\'app.';

  @override
  String get wotBuildingTitle => 'Construction de ton fil Découvrir';

  @override
  String get wotBuildingBody =>
      'Lecture de qui les personnes que tu suis suivent aussi, et préparation de Découvrir.';

  @override
  String get wotDiscoverHint =>
      'Seulement ton réseau de confiance : les personnes que tu suis, et celles qu\'assez d\'entre elles suivent.';

  @override
  String get wotDiscoverSignIn =>
      'Découvrir affiche ton réseau de confiance. Connecte-toi et, la première fois, Mialuna lit qui tu suis et construit ce fil. Les ouvertures suivantes le réutilisent.';

  @override
  String get wotDiscoverEmpty =>
      'Pas encore de publications de ton réseau de confiance.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Vérification de qui tes suivis suivent… $done sur $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Ton réseau : $direct personnes que tu suis plus $indirect suivies par assez d\'entre elles. Mis à jour $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Impossible de calculer ton réseau : $reason';
  }

  @override
  String get wotNoFollows => 'tu ne suis encore personne';

  @override
  String get messageRequests => 'Demandes de message';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversations hors de ton réseau de confiance',
      one: '1 conversation hors de ton réseau de confiance',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'De personnes hors de ton réseau de confiance. Elles ne comptent pas comme non lues. Réponds pour déplacer une conversation dans ta boîte.';

  @override
  String get storyViewsSetting => 'Montrer que j\'ai vu leurs stories';

  @override
  String get storyViewsSettingExplain =>
      'Quand tu regardes une story, un accusé est envoyé à son auteur, chiffré pour que lui seul puisse le lire. Il indique ton nom à côté du sien ; les relays ne voient rien. S\'il ne peut pas être remis, il est gardé et réessayé plus tard. Désactive pour regarder sans prévenir personne : les accusés pas encore envoyés sont écartés (un déjà remis ne peut pas être repris).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vu par $count personnes',
      one: 'Vu par 1 personne',
      zero: 'Aucune vue pour le moment',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Personne n\'a encore regardé cette story, ou leurs accusés ne te sont pas parvenus.';

  @override
  String get storyViewsHint =>
      'Seules les personnes qui l\'autorisent envoient un accusé, le nombre réel peut donc être plus élevé.';

  @override
  String get systemNotifications => 'Notifications système';

  @override
  String get systemNotificationsExplain =>
      'Affiche une notification sur ton téléphone quand quelque chose de nouveau arrive pendant que Mialuna est en arrière-plan. Les messages privés n\'affichent jamais leur texte, même sur l\'écran de verrouillage. Android met en pause les apps longtemps en arrière-plan, donc les notifications arrivent tant que Mialuna tourne encore.';

  @override
  String get systemNotificationsBlocked =>
      'Les notifications sont désactivées pour Mialuna dans les réglages du téléphone.';

  @override
  String get systemNotificationsOpenSettings => 'Ouvrir les réglages';

  @override
  String get systemNotificationsBattery =>
      'Android endort les apps quelques minutes après l\'extinction de l\'écran, et les notifications s\'arrêtent avec elles. Pour continuer à les recevoir, règle l\'utilisation de la batterie de Mialuna sur “Sans restriction”.';

  @override
  String get systemNotificationsBatteryAction => 'Ouvrir les réglages batterie';

  @override
  String get newFollowersSetting => 'Afficher les nouveaux abonnés';

  @override
  String get newFollowersSettingExplain =>
      'Les nouveaux abonnés apparaissent dans Notifications et sur ton téléphone. Désactive si les suivis t\'inondent : les j\'aime, commentaires et zaps restent affichés.';

  @override
  String get systemNotificationMessage => 't\'a envoyé un message privé';

  @override
  String get systemNotificationNewMessage => 'Nouveau message privé';

  @override
  String get systemNotificationNew => 'Nouvelle notification';

  @override
  String get notificationChannelSocial =>
      'Réactions, commentaires, zaps et abonnés';

  @override
  String get notificationChannelMessages => 'Messages privés';

  @override
  String get zapInvoiceMismatch =>
      'La facture ne correspond pas au montant choisi. Rien n\'a été payé.';

  @override
  String get storyYourStory => 'Ta story';

  @override
  String get storyNew => 'Nouvelle story';

  @override
  String get storyAddSemantics => 'Ajouter à ta story';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories',
      one: '1 story',
    );
    return 'Ta story, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Taille du texte';

  @override
  String get storyPickPrompt => 'Choisis une photo ou une vidéo pour ta story';

  @override
  String get storyEditPhoto => 'Modifier la photo';

  @override
  String get storyCaption => 'Légende';

  @override
  String get storyDiscardTitle => 'Abandonner cette story ?';

  @override
  String get storyDiscard => 'Abandonner';

  @override
  String get storyShare => 'Partager';

  @override
  String get storyShared => 'Story partagée';

  @override
  String get deletePost => 'Supprimer';

  @override
  String get deletePostTitle => 'Supprimer cette publication ?';

  @override
  String get deleteStoryTitle => 'Supprimer cette story ?';

  @override
  String get deletePostBody =>
      'Mialuna demandera à tes relays de la supprimer et aux serveurs médias de supprimer ses photos ou sa vidéo. Un relay qui ignore la demande, ou quelqu\'un qui a déjà une copie, peut encore l\'avoir.';

  @override
  String get deletePrivateBody =>
      'Une publication pour amis proches ne peut pas être rappelée des relays. Mialuna dira aux apps de tes amis de la retirer et demandera au serveur média de supprimer ses fichiers chiffrés. Un ami qui a déjà une copie peut encore l\'avoir.';

  @override
  String get deletingPost => 'Suppression…';

  @override
  String get postDeleted => 'Supprimé.';

  @override
  String get postWasDeleted => 'Cette publication a été supprimée.';

  @override
  String get deleteNotAllowed =>
      'Seul le compte qui l\'a publiée peut la supprimer.';

  @override
  String deleteFailed(Object reason) {
    return 'Suppression impossible : $reason';
  }

  @override
  String get deleteNoRelay =>
      'Aucun relay n\'a accepté la demande de suppression, elle est donc encore en ligne. Vérifie ta connexion et réessaie.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Le média n\'a pas pu être retiré de $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Ton signataire n\'a pas autorisé le retrait du média, les fichiers sont donc encore sur le serveur média.';

  @override
  String deleteFriendsMissed(Object count) {
    return '$count de tes amis proches n\'ont pas pu être prévenus, elle peut donc rester sur leurs téléphones.';
  }

  @override
  String get storyCleanupSetting => 'Supprimer mes stories à expiration';

  @override
  String get storyCleanupSettingExplain =>
      'Après 24 heures, Mialuna demande à tes relays et à tes serveurs médias de supprimer tes stories, photos et vidéos comprises. Un serveur qui ignore la demande, ou quelqu\'un qui a gardé une copie, peut encore les avoir.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Ton signataire doit approuver chaque nettoyage, donc ça attend que tu le demandes. Stories expirées en attente : $count.';
  }

  @override
  String get storyCleanupNow => 'Supprimer maintenant';

  @override
  String get storyCleanupDone => 'Stories expirées supprimées.';

  @override
  String get storyCleanupPartly =>
      'Certaines n\'ont pas encore pu être supprimées ; Mialuna réessaiera.';
}
