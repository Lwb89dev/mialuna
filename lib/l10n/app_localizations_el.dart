// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get syncUpToDate => 'Ενημερωμένο';

  @override
  String get syncFailed => 'Ο συγχρονισμός απέτυχε';

  @override
  String get relaysUpdatedFromProfile =>
      'Τα Relays ενημερώθηκαν από το προφίλ σου (NIP-65)';

  @override
  String get relayListPublished => 'Η λίστα Relay δημοσιεύτηκε';

  @override
  String get mediaServersUpdatedFromProfile =>
      'Οι διακομιστές πολυμέσων ενημερώθηκαν από το προφίλ σου';

  @override
  String get tabHome => 'Home';

  @override
  String get tabDiscover => 'Ανακάλυψη';

  @override
  String get tabCreate => 'Δημιουργία';

  @override
  String get tabReels => 'Reels';

  @override
  String get tabProfile => 'Προφίλ';

  @override
  String get signInToUploadMedia => 'Συνδέσου για να ανεβάσεις πολυμέσα.';

  @override
  String get noMediaServer =>
      'Δεν έχει οριστεί διακομιστής πολυμέσων. Πρόσθεσε έναν στις Ρυθμίσεις.';

  @override
  String serverNoResponse(Object server) {
    return '$server: καμία απόκριση';
  }

  @override
  String serverUnreachable(Object server, Object error) {
    return '$server: μη προσβάσιμο ($error)';
  }

  @override
  String uploadRejected(Object reason) {
    return 'Η μεταφόρτωση απορρίφθηκε — $reason';
  }

  @override
  String noServerAcceptedFile(Object reasons) {
    return 'Κανένας διακομιστής δεν δέχτηκε το αρχείο — $reasons';
  }

  @override
  String get blossomInvalidResponse => 'μη έγκυρη απόκριση';

  @override
  String get blossomInvalidFileUrl => 'μη έγκυρη διεύθυνση αρχείου';

  @override
  String get blossomServerAlteredFile => 'ο διακομιστής τροποποίησε το αρχείο';

  @override
  String get blossomBadRequest => 'μη έγκυρο αίτημα';

  @override
  String get blossomUnauthorized => 'η εξουσιοδότηση απορρίφθηκε';

  @override
  String get blossomPaymentRequired => 'απαιτείται πληρωμή';

  @override
  String get blossomForbidden => 'δεν επιτρέπεται';

  @override
  String get blossomLengthRequired => 'λείπει το μέγεθος';

  @override
  String get blossomTooLarge => 'πολύ μεγάλο αρχείο';

  @override
  String get blossomUnsupportedType => 'η μορφή δεν γίνεται δεκτή';

  @override
  String get blossomTooManyRequests => 'πάρα πολλά αιτήματα';

  @override
  String get blossomServerError => 'σφάλμα διακομιστή';

  @override
  String get cipherInvalidKey => 'Μη έγκυρο κλειδί';

  @override
  String get cipherTruncated => 'Το κρυπτογραφημένο αρχείο είναι κομμένο';

  @override
  String get cipherMismatch =>
      'Το αρχείο δεν ταιριάζει με το κλειδί: τροποποιήθηκε ή καταστράφηκε';

  @override
  String get sanitizeHeifNeedsAsync =>
      'Μορφή HEIC/AVIF: η μετατροπή απαιτεί sanitizeAsync';

  @override
  String get sanitizeWebmUnsupported =>
      'Το βίντεο WebM/MKV δεν υποστηρίζεται: χρησιμοποίησε MP4 ή MOV ώστε να αφαιρεθούν τα μεταδεδομένα πριν τη μεταφόρτωση.';

  @override
  String get sanitizeUnknownFormat =>
      'Άγνωστη μορφή αρχείου: φωτογραφίες JPEG/PNG/WebP/GIF ή βίντεο MP4/MOV.';

  @override
  String sanitizeLeftovers(Object items) {
    return 'Δεν αφαιρέθηκαν όλα τα μεταδεδομένα ($items): το αρχείο δεν ανέβηκε.';
  }

  @override
  String sanitizeProcessingFailed(Object error) {
    return 'Δεν ήταν δυνατή η επεξεργασία του αρχείου: $error';
  }

  @override
  String get sanitizeJpegInvalid => 'Μη έγκυρο JPEG';

  @override
  String get sanitizeJpegTruncated => 'Κομμένο JPEG';

  @override
  String get sanitizeJpegNoSize => 'JPEG χωρίς διαστάσεις';

  @override
  String get sanitizeJpegUndecodable => 'Το JPEG δεν αποκωδικοποιείται';

  @override
  String get sanitizePngTruncated => 'Κομμένο PNG';

  @override
  String get sanitizePngInvalid => 'Μη έγκυρο PNG';

  @override
  String get sanitizeGifInvalid => 'Μη έγκυρο GIF';

  @override
  String get sanitizeGifTruncated => 'Κομμένο GIF';

  @override
  String get sanitizeWebpTruncated => 'Κομμένο WebP';

  @override
  String get sanitizeWebpInvalid => 'Μη έγκυρο WebP';

  @override
  String get sanitizeMp4Invalid => 'Μη έγκυρο βίντεο MP4/MOV';

  @override
  String get sanitizeConversionFailed => 'Η μετατροπή απέτυχε';

  @override
  String get sanitizeHeifUnsupported =>
      'Αυτή η μορφή (HEIC/AVIF) δεν μετατρέπεται σε αυτή τη συσκευή. Διάλεξε φωτογραφία JPEG ή PNG.';

  @override
  String get privateMediaNotEncrypted =>
      'Τα πολυμέσα δεν είναι κρυπτογραφημένα';

  @override
  String serverReplied(Object status) {
    return 'Ο διακομιστής απάντησε $status';
  }

  @override
  String get fileTooLarge => 'Πολύ μεγάλο αρχείο';

  @override
  String get serverFileNotOriginal =>
      'Το αρχείο στον διακομιστή δεν είναι το πρωτότυπο';

  @override
  String get contentMismatch => 'Το περιεχόμενο δεν ταιριάζει';

  @override
  String get mediaUnreachable => 'Πολυμέσα μη προσβάσιμα';

  @override
  String get amberInvalidKey => 'Το Amber επέστρεψε μη έγκυρο κλειδί';

  @override
  String get amberNoKey => 'Το Amber δεν επέστρεψε κλειδί';

  @override
  String get amberRequestRejected => 'Το αίτημα απορρίφθηκε στο Amber';

  @override
  String get amberAndroidOnly => 'Το Amber είναι διαθέσιμο μόνο σε Android';

  @override
  String get amberEmptySignature => 'Το Amber επέστρεψε κενή υπογραφή';

  @override
  String get amberSignRejected => 'Η υπογραφή απορρίφθηκε στο Amber';

  @override
  String get amberTimeout => 'Το Amber δεν απάντησε εγκαίρως';

  @override
  String get amberEmptyResponse => 'Το Amber επέστρεψε κενή απόκριση';

  @override
  String get bunkerInvalidUrl => 'Μη έγκυρο URL bunker';

  @override
  String get bunkerNoRelay => 'Το bunker δεν αναφέρει κανένα relay';

  @override
  String get bunkerWebAuth =>
      'Το bunker απαιτεί εξουσιοδότηση ιστού (το auth_url δεν υποστηρίζεται)';

  @override
  String get bunkerInvalidKey => 'Το bunker δεν επέστρεψε έγκυρο κλειδί';

  @override
  String get signerInvalidResponse =>
      'Ο υπογράφων επέστρεψε μη έγκυρο υπογεγραμμένο συμβάν';

  @override
  String get bunkerTimeout => 'Το Bunker έληξε';

  @override
  String get nwcInvalidUri => 'Μη έγκυρο URI NWC';

  @override
  String get nwcNoRelay => 'Το URI NWC δεν αναφέρει κανένα relay';

  @override
  String get nwcNoSecret => 'Το URI NWC δεν περιέχει έγκυρο μυστικό';

  @override
  String get nwcTimeout => 'Το πορτοφόλι έληξε';

  @override
  String get signerNoPrivateMessages =>
      'Αυτή η μέθοδος σύνδεσης δεν υποστηρίζει ιδιωτικά μηνύματα';

  @override
  String get zapNotSupported => 'Αυτή η διεύθυνση δεν υποστηρίζει Nostr zaps';

  @override
  String zapAmountOutOfRange(Object min, Object max) {
    return 'Ποσό εκτός ορίων ($min–$max sats)';
  }

  @override
  String get commentNotSent =>
      'Το σχόλιο δεν στάλθηκε. Δοκίμασε ξανά αργότερα.';

  @override
  String get comments => 'Σχόλια';

  @override
  String get noCommentsYet => 'Δεν υπάρχουν σχόλια ακόμα.';

  @override
  String get signInToComment => 'Συνδέσου για να σχολιάσεις.';

  @override
  String get addComment => 'Πρόσθεσε σχόλιο…';

  @override
  String get signInToPublish => 'Συνδέσου για να δημοσιεύσεις.';

  @override
  String get addMediaFirst =>
      'Πρόσθεσε τουλάχιστον μία φωτογραφία ή ένα βίντεο πριν τη δημοσίευση.';

  @override
  String get removingMetadata => 'Αφαίρεση μεταδεδομένων…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Μεταφόρτωση $current από $total…';
  }

  @override
  String get creatingPreview => 'Δημιουργία προεπισκόπησης…';

  @override
  String uploadFailed(Object error) {
    return 'Η μεταφόρτωση απέτυχε: $error';
  }

  @override
  String get publishing => 'Δημοσίευση…';

  @override
  String noRelayAcceptedPost(Object reason) {
    return 'Κανένα relay$reason δεν δέχτηκε την ανάρτηση. Το περιεχόμενο μένει στα προσχέδια.';
  }

  @override
  String get privateNeedsKeySigner =>
      'Αυτή η μέθοδος σύνδεσης δεν υποστηρίζει ιδιωτικό περιεχόμενο. Χρησιμοποίησε Amber, bunker ή το τοπικό κλειδί.';

  @override
  String get closeFriendsListEmptyAddSomeone =>
      'Η λίστα στενών φίλων σου είναι άδεια: πρόσθεσε κάποιον.';

  @override
  String get fileOver100Mb =>
      'Το αρχείο είναι πάνω από 100 MB: αυτό είναι το όριο για τους στενούς φίλους (κρυπτογραφείται ολόκληρο στο τηλέφωνό σου).';

  @override
  String get encryptingOnPhone => 'Κρυπτογράφηση στο τηλέφωνό σου…';

  @override
  String noServerAcceptedEncrypted(Object details) {
    return 'Κανένας διακομιστής πολυμέσων δεν δέχτηκε το κρυπτογραφημένο αρχείο. Δεν δημοσιεύεται σε καθαρή μορφή. Πρόσθεσε στις Ρυθμίσεις διακομιστή που δέχεται κρυπτογραφημένα αρχεία (για παράδειγμα cdn.hzrd149.com). $details';
  }

  @override
  String get sendingToFriends => 'Αποστολή στους φίλους…';

  @override
  String sendingToFriendsProgress(Object done, Object total) {
    return 'Αποστολή στους φίλους $done/$total…';
  }

  @override
  String noFriendReceivedPost(Object reason) {
    return 'Κανένας φίλος δεν έλαβε το post$reason. Το περιεχόμενο μένει στα προσχέδια.';
  }

  @override
  String sentToCloseFriends(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Στάλθηκε σε $count στενούς φίλους 🔒',
      one: 'Στάλθηκε σε 1 στενό φίλο 🔒',
    );
    return '$_temp0';
  }

  @override
  String sentToFriendsWithMisses(int delivered, Object missed) {
    String _temp0 = intl.Intl.pluralLogic(
      delivered,
      locale: localeName,
      other: 'Στάλθηκε σε $delivered φίλους.',
      one: 'Στάλθηκε σε 1 φίλο.',
    );
    return '$_temp0 Οι $missed δεν το έλαβαν (τα ιδιωτικά μηνύματα είναι κλειστά).';
  }

  @override
  String get altText => 'Κείμενο alt';

  @override
  String get altTextHint =>
      'Περίγραψε το περιεχόμενο για όσους δεν το βλέπουν…';

  @override
  String get cancel => 'Ακύρωση';

  @override
  String get save => 'Αποθήκευση';

  @override
  String get momentPublished => 'Η στιγμή δημοσιεύτηκε ✨';

  @override
  String get newMoment => 'Νέα στιγμή';

  @override
  String get publish => 'Δημοσίευση';

  @override
  String get guestMode => 'Λειτουργία επισκέπτη';

  @override
  String get signInToPostMoments =>
      'Συνδέσου για να δημοσιεύσεις τις στιγμές σου.';

  @override
  String get signIn => 'Σύνδεση';

  @override
  String get kindPhoto => 'Φωτογραφία';

  @override
  String get kindVideo => 'Βίντεο';

  @override
  String get kindReel => 'Reel';

  @override
  String get kindStory => 'Ιστορία';

  @override
  String get storyExpiryNote =>
      'Οι ιστορίες λήγουν μετά από 24 ώρες στα relays που τηρούν το NIP-40, αλλά άλλοι μπορούν ακόμα να τις αποθηκεύσουν ή να τις αρχειοθετήσουν.';

  @override
  String get fromGallery => 'Από τη συλλογή';

  @override
  String get galleryLongPressVideo =>
      'Συλλογή (παρατεταμένο πάτημα για βίντεο)';

  @override
  String get addVideo => 'Προσθήκη βίντεο';

  @override
  String get camera => 'Κάμερα';

  @override
  String get exifRemovedNote =>
      'Τα μεταδεδομένα τοποθεσίας (EXIF) αφαιρούνται αυτόματα.';

  @override
  String get writeCaption => 'Γράψε λεζάντα…';

  @override
  String get privatePostNote =>
      'Ιδιωτική ανάρτηση: χωρίς δημόσια hashtag, δεν βρίσκεται από την αναζήτηση.';

  @override
  String willPublishAs(Object caption) {
    return 'Θα δημοσιευτεί ως: \"$caption\"';
  }

  @override
  String get tapThumbnailForAlt =>
      'Πάτα μια μικρογραφία για να προσθέσεις κείμενο alt.';

  @override
  String get sensitiveContent => 'Ευαίσθητο περιεχόμενο';

  @override
  String get sensitiveContentNote =>
      'Η ανάρτηση κρύβεται πίσω από προειδοποίηση (NIP-36).';

  @override
  String get uploadingMedia => 'Μεταφόρτωση πολυμέσων…';

  @override
  String get audiencePublic => 'Δημόσιο';

  @override
  String get closeFriends => 'Στενοί φίλοι';

  @override
  String get signerCannotPublishCloseFriends =>
      'Με αυτή τη μέθοδο σύνδεσης δεν δημοσιεύεις για στενούς φίλους: χρησιμοποίησε Amber, bunker ή το τοπικό κλειδί.';

  @override
  String get closeFriendsEmptyPrompt =>
      'Η λίστα σου είναι άδεια: πρόσθεσε όσους μπορούν να δουν αυτή την ανάρτηση.';

  @override
  String onlyYourCloseFriendsSee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Μόνο οι $count στενοί φίλοι σου θα το δουν. Φωτογραφίες και βίντεο κρυπτογραφούνται στο τηλέφωνό σου πριν ανέβουν.',
      one: 'Μόνο 1 στενός φίλος σου θα το δει. Φωτογραφίες και βίντεο κρυπτογραφούνται στο τηλέφωνό σου πριν ανέβουν.',
    );
    return '$_temp0';
  }

  @override
  String get addFriends => 'Προσθήκη φίλων';

  @override
  String get manageList => 'Διαχείριση λίστας';

  @override
  String get edit => 'Επεξεργασία';

  @override
  String get reset => 'Επαναφορά';

  @override
  String get apply => 'Εφαρμογή';

  @override
  String get cropFree => 'Ελεύθερο';

  @override
  String get cropOriginal => 'Αρχικό';

  @override
  String get rotate => 'Περιστροφή';

  @override
  String get flip => 'Αναστροφή';

  @override
  String get brightness => 'Φωτεινότητα';

  @override
  String get contrast => 'Αντίθεση';

  @override
  String get saturation => 'Κορεσμός';

  @override
  String postsByAuthor(Object author) {
    return 'Αναρτήσεις από $author…';
  }

  @override
  String get searchHint => 'Αναζήτηση ατόμων, hashtag ή λέξεων…';

  @override
  String get clear => 'Καθαρισμός';

  @override
  String get recent => 'Πρόσφατα';

  @override
  String get searchDependsOnRelays =>
      'Η αναζήτηση εξαρτάται από τα ρυθμισμένα relays: τα αποτελέσματα μπορεί να είναι μερικά.';

  @override
  String get recentPostsEverywhere =>
      'Πρόσφατες αναρτήσεις από όλο το δίκτυο, και από άτομα που δεν ακολουθείς.';

  @override
  String get noResultsOnRelays => 'Κανένα αποτέλεσμα στα ρυθμισμένα relays.';

  @override
  String get noRecentPostsFromFollowed =>
      'Δεν υπάρχουν πρόσφατες αναρτήσεις από όσους ακολουθείς.';

  @override
  String get noMomentsFound =>
      'Δεν βρέθηκαν στιγμές στα relays. Έλεγξε τη σύνδεσή σου.';

  @override
  String get loadFailed => 'Η φόρτωση απέτυχε';

  @override
  String get notifications => 'Ειδοποιήσεις';

  @override
  String get messages => 'Μηνύματα';

  @override
  String get homeEmptyFollowsNobody =>
      'Οι αναρτήσεις όσων ακολουθείς εμφανίζονται εδώ.\nΔεν ακολουθείς ακόμα κανέναν: ανακάλυψε ενδιαφέροντα άτομα και προφίλ.';

  @override
  String get discoverPeople => 'Ανακάλυψε άτομα';

  @override
  String get homeEmpty =>
      'Καμία στιγμή ακόμα.\nΤράβηξε προς τα κάτω για ανανέωση ή δημοσίευσε το πρώτο σου πλάνο.';

  @override
  String get retry => 'Δοκίμασε ξανά';

  @override
  String get seenEverything => 'Τα είδες όλα προς το παρόν ✨';

  @override
  String get discoverMoreProfiles => 'Ανακάλυψε κι άλλα προφίλ';

  @override
  String get feedFollowing => 'Ακολουθείς';

  @override
  String get signInToSeeFollowed =>
      'Συνδέσου για να δεις αναρτήσεις από όσους ακολουθείς';

  @override
  String get videoPreview => 'Προεπισκόπηση βίντεο';

  @override
  String get cannotOpenPrivateVideo => 'Δεν ανοίγει το ιδιωτικό βίντεο';

  @override
  String get cannotPlayVideo => 'Δεν παίζει το βίντεο';

  @override
  String get pauseVideo => 'Παύση βίντεο';

  @override
  String get playVideo => 'Αναπαραγωγή βίντεο';

  @override
  String errorTapToRetry(Object error) {
    return '$error — πάτα για επανάληψη';
  }

  @override
  String get soundOn => 'Ήχος ενεργός';

  @override
  String get soundOff => 'Ήχος ανενεργός';

  @override
  String get postImage => 'Εικόνα ανάρτησης';

  @override
  String get imageUnavailable => 'Η εικόνα δεν είναι διαθέσιμη';

  @override
  String errorTapToRetryNewline(Object message) {
    return '$message\nΠάτα για επανάληψη';
  }

  @override
  String get cannotOpenPrivateContent =>
      'Δεν ανοίγει αυτό το ιδιωτικό περιεχόμενο';

  @override
  String get privateImage => 'Ιδιωτική εικόνα';

  @override
  String get invalidImage => 'Μη έγκυρη εικόνα';

  @override
  String get more => 'Περισσότερα';

  @override
  String get removeFromSaved => 'Αφαίρεση από τα αποθηκευμένα';

  @override
  String get copyLink => 'Αντιγραφή συνδέσμου';

  @override
  String get muteAuthor => 'Σίγαση συντάκτη';

  @override
  String get blockAuthor => 'Αποκλεισμός συντάκτη';

  @override
  String get report => 'Αναφορά';

  @override
  String get like => 'Μου αρέσει';

  @override
  String get sendInMessage => 'Αποστολή με μήνυμα';

  @override
  String get zapOptional => 'Zap (προαιρετικό)';

  @override
  String get closeFriendsOnlyNote =>
      'Ορατό μόνο στους στενούς φίλους. Τα like και οι απαντήσεις πάνε μόνο στον συντάκτη.';

  @override
  String get likeFailed => 'Δεν στάλθηκε το like';

  @override
  String get nostrLinkCopied => 'Ο σύνδεσμος Nostr αντιγράφηκε';

  @override
  String get authorMuted => 'Ο συντάκτης σε σίγαση';

  @override
  String get authorBlocked => 'Ο συντάκτης αποκλείστηκε';

  @override
  String get reportSent => 'Η αναφορά στάλθηκε (NIP-56)';

  @override
  String get signInToReport => 'Συνδέσου για αναφορά';

  @override
  String minutesAgo(Object minutes) {
    return 'πριν $minutes λ';
  }

  @override
  String get show => 'Εμφάνιση';

  @override
  String get chatEmptyHint =>
      'Γράψε το πρώτο μήνυμα.\nΕίναι κρυπτογραφημένο: μόνο οι δυο σας το βλέπετε.';

  @override
  String get messageHint => 'Μήνυμα…';

  @override
  String get send => 'Αποστολή';

  @override
  String get notSentSuffix => ' δεν στάλθηκε';

  @override
  String get contentUnavailable =>
      'Μη διαθέσιμο περιεχόμενο (έληξε ή δεν βρέθηκε στα relays)';

  @override
  String get signInToSendPrivateMessages =>
      'Συνδέσου για να στείλεις ιδιωτικά μηνύματα.';

  @override
  String get cannotMessageYourself => 'Δεν μπορείς να γράψεις στον εαυτό σου.';

  @override
  String get recipientNoPrivateMessages =>
      'Αυτό το άτομο δεν έχει ενεργοποιήσει ακόμα τα ιδιωτικά μηνύματα.';

  @override
  String noRecipientRelayAccepted(Object reason) {
    return 'Κανένα relay$reason παραλήπτη δεν δέχτηκε το μήνυμα.';
  }

  @override
  String sendFailed(Object error) {
    return 'Η αποστολή απέτυχε: $error';
  }

  @override
  String get signInToReadMessages =>
      'Συνδέσου για να διαβάζεις και να στέλνεις ιδιωτικά μηνύματα.';

  @override
  String get signerNoPrivateMessagesLong =>
      'Δεν μπορείς να χρησιμοποιήσεις ιδιωτικά μηνύματα με αυτή τη μέθοδο σύνδεσης. Συνδέσου με Amber, bunker ή το τοπικό κλειδί.';

  @override
  String get inboxEmpty =>
      'Καμία συνομιλία.\nΠάτα το μολύβι για να γράψεις σε κάποιον ή προώθησε μια στιγμή με το εικονίδιο ✈ κάτω από κάθε ανάρτηση.';

  @override
  String get newMessage => 'Νέο μήνυμα';

  @override
  String get privateMessagesEnabled => 'Ιδιωτικά μηνύματα ενεργά';

  @override
  String get enableMessagesFailed => 'Δεν ενεργοποιήθηκαν. Δοκίμασε ξανά.';

  @override
  String get enablePrivateMessages => 'Ενεργοποίηση ιδιωτικών μηνυμάτων';

  @override
  String enablePrivateMessagesExplain(Object count) {
    return 'Για να λαμβάνεις μηνύματα πες σε ποια relays πρέπει να φτάνουν. Δημοσιεύεται μια μικρή λίστα (NIP-17) με $count προεπιλεγμένα relays: μπορείς να την αλλάξεις αργότερα. Τα μηνύματα μένουν κρυπτογραφημένα: τα relays δεν βλέπουν ούτε ποιος γράφει ούτε το κείμενο.';
  }

  @override
  String get turnOn => 'Ενεργοποίηση';

  @override
  String get searchByNameOrUsername => 'Αναζήτηση με όνομα ή όνομα χρήστη';

  @override
  String get searching => 'Αναζήτηση…';

  @override
  String get noOneWithNameHint =>
      'Κανείς με αυτό το όνομα. Δοκίμασε λιγότερα γράμματα ή μια διεύθυνση όπως name@domain.com.';

  @override
  String get sent => 'Στάλθηκε';

  @override
  String sentToPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Στάλθηκε σε $count άτομα',
      one: 'Στάλθηκε σε 1 άτομο',
    );
    return '$_temp0';
  }

  @override
  String sentToPeopleWithFailure(int count, Object failure) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Στάλθηκε σε $count άτομα. $failure',
      one: 'Στάλθηκε σε 1 άτομο. $failure',
    );
    return '$_temp0';
  }

  @override
  String get signerNoPrivateMessagesShort =>
      'Δεν μπορείς να χρησιμοποιήσεις ιδιωτικά μηνύματα με αυτή τη μέθοδο σύνδεσης.';

  @override
  String get followToStartOrSearch =>
      'Ακολούθησε κάποιον για αρχή ή αναζήτησε με όνομα.';

  @override
  String get addMessage => 'Πρόσθεσε μήνυμα…';

  @override
  String sendWithCount(Object count) {
    return 'Αποστολή ($count)';
  }

  @override
  String get linkCopied => 'Ο σύνδεσμος αντιγράφηκε';

  @override
  String get noNotifications => 'Καμία ειδοποίηση αυτή τη στιγμή.';

  @override
  String get notificationsDependOnRelays =>
      'Οι ειδοποιήσεις εξαρτώνται από τα relays: μπορεί να είναι ελλιπείς.';

  @override
  String get reactedToYourMoment => 'αντέδρασε στη στιγμή σου';

  @override
  String commentedText(Object text) {
    return 'σχολίασε: $text';
  }

  @override
  String sentYouSats(Object sats, Object comment) {
    return 'σου έστειλε $sats sats$comment';
  }

  @override
  String get sentYouZap => 'σου έστειλε ένα zap';

  @override
  String get startedFollowingYou => 'άρχισε να σε ακολουθεί';

  @override
  String get amberNotFound => 'Το Amber δεν βρέθηκε';

  @override
  String get amberExplain =>
      'Το Amber είναι υπογράφων Nostr που κρατά το ιδιωτικό σου κλειδί έξω από τη Mialuna. Εγκατάστησέ το και δοκίμασε ξανά.';

  @override
  String get downloadFromFdroid => 'Λήψη από το F-Droid';

  @override
  String get continueWithAmber => 'Συνέχεια με Amber';

  @override
  String get amberRecommended =>
      'Προτείνεται: το ιδιωτικό κλειδί σου μένει ασφαλές στο Amber.';

  @override
  String get amberNotDetected =>
      'Το Amber δεν εντοπίστηκε: εγκατάστησέ το για την προτεινόμενη σύνδεση.';

  @override
  String get exploreWithoutAccount => 'Περιήγηση χωρίς λογαριασμό';

  @override
  String get remoteBunker => 'Απομακρυσμένο bunker (NIP-46)';

  @override
  String get invalidBunkerUrlDot => 'Μη έγκυρο URL bunker.';

  @override
  String get connectBunker => 'Σύνδεση bunker';

  @override
  String get advancedNsec => 'Σύνθετη σύνδεση (nsec)';

  @override
  String get nsecWarning =>
      'Προειδοποίηση: η επικόλληση του ιδιωτικού κλειδιού είναι επικίνδυνη. Μην το μοιραστείς με κανέναν. Σε Android προτίμησε το Amber.';

  @override
  String get invalidNsec => 'Μη έγκυρο κλειδί nsec.';

  @override
  String get signInWithNsec => 'Σύνδεση με nsec';

  @override
  String get tagline => 'Οι στιγμές σου, κάτω από το ίδιο φεγγάρι.';

  @override
  String get skip => 'Παράλειψη';

  @override
  String get permissionsAndWallet => 'Άδειες και πορτοφόλι';

  @override
  String get permissionsExplain =>
      'Σου επιτρέπουν μόνο να δημοσιεύεις και να λαμβάνεις ειδοποιήσεις. Μπορείς να τις αλλάξεις οποιαδήποτε στιγμή στις ρυθμίσεις συστήματος.';

  @override
  String get photosAndVideos => 'Φωτογραφίες και βίντεο';

  @override
  String get toUploadYourMoments => 'Για ανέβασμα των στιγμών σου';

  @override
  String get allow => 'Επίτρεψε';

  @override
  String get reactionsCommentsZaps => 'Αντιδράσεις, σχόλια και zaps';

  @override
  String get lightningWalletOptional => 'Πορτοφόλι Lightning (προαιρετικό)';

  @override
  String get nwcExplain =>
      'Σύνδεσε πορτοφόλι Nostr Wallet Connect για να στέλνεις zaps χωρίς να βγαίνεις από την εφαρμογή.';

  @override
  String get walletConnected => 'Το πορτοφόλι συνδέθηκε';

  @override
  String get disconnect => 'Αποσύνδεση';

  @override
  String get connectWallet => 'Σύνδεση πορτοφολιού';

  @override
  String get getStarted => 'Ξεκίνα';

  @override
  String get welcome1 =>
      'Η Mialuna είναι οπτικό κοινωνικό δίκτυο: φωτογραφίες, βίντεο, Reels και ιστορίες — ποτέ αναρτήσεις μόνο με κείμενο.';

  @override
  String get welcome2 =>
      'Τρέχει στο Nostr, ένα ανοιχτό πρωτόκολλο: η ταυτότητά σου είναι κλειδί που σου ανήκει, όχι λογαριασμός που μια εταιρεία μπορεί να πάρει. Χωρίς διαφημίσεις, χωρίς ιχνηλάτες, χωρίς κεντρικούς διακομιστές.';

  @override
  String get welcome3 =>
      'Μοιράσου το φως σου με ανθρώπους παντού, από κάθε εφαρμογή που μιλά την ίδια ανοιχτή γλώσσα.';

  @override
  String onboardingWot(int min) {
    return 'Το δίκτυο εμπιστοσύνης είναι πάντα ενεργό. Την πρώτη φορά που ανοίγεις τη Mialuna διαβάζει ποιους ακολουθείς και φτιάχνει τη ροή Ανακάλυψη από αυτό το δίκτυο: εσύ, όσοι ακολουθείς και όποιος ακολουθείται από τουλάχιστον $min από αυτούς. Τις επόμενες φορές η ροή είναι ήδη έτοιμη.';
  }

  @override
  String get publicAndPrivate => 'Δημόσιο και ιδιωτικό';

  @override
  String get publicAndPrivateIntro =>
      'Η Mialuna βασίζεται στο Nostr, ένα ανοιχτό δίκτυο. Ό,τι δημοσιεύεις είναι δημόσιο: αναρτήσεις, φωτογραφίες και βίντεο μένουν ορατά σε όποιον έχει τον σύνδεσμο, ακόμη και έξω από τη Mialuna.';

  @override
  String get closeFriendsExplain1 =>
      'Μόνο τα άτομα αυτής της λίστας λαμβάνουν τις αναρτήσεις, τις ιστορίες και τα βίντεο \"Στενοί φίλοι\". Η λίστα είναι μέσα στην ανάρτηση και δεν την διαλέγεις κάθε φορά.';

  @override
  String get closeFriendsExplain2 =>
      'Φωτογραφίες και βίντεο κρυπτογραφούνται στο τηλέφωνό σου πριν ανέβουν. Οι διακομιστές αρχείων (Blossom) δεν κρυπτογραφούν τίποτα μόνοι τους: για αυτό το κάνει η Mialuna, και ο διακομιστής βλέπει μόνο μη αναγνώσιμα δεδομένα. Όποιος βρει τη διεύθυνση του αρχείου δεν μπορεί να το ανοίξει.';

  @override
  String get closeFriendsExplain3 =>
      'Δεν είναι απόλυτη εγγύηση: όποιος λάβει μια ανάρτηση μπορεί να βγάλει στιγμιότυπο, και η αφαίρεση φίλου ισχύει μόνο για μελλοντικές αναρτήσεις.';

  @override
  String get closeFriendsExplain4 =>
      'Κάθε φίλος πρέπει να χρησιμοποιεί τη Mialuna με ενεργά ιδιωτικά μηνύματα. Άλλοι πελάτες Nostr δεν δείχνουν αυτές τις αναρτήσεις.';

  @override
  String get closeFriendsExplain5 =>
      'Οι δημόσιες αναρτήσεις μένουν δημόσιες: τα αρχεία τους είναι ορατά σε όποιον έχει τον σύνδεσμο.';

  @override
  String get closeFriendsExplain6 =>
      'Αν κανένας διακομιστής σου δεν δέχεται κρυπτογραφημένα αρχεία, η ανάρτηση δεν δημοσιεύεται: ποτέ σε καθαρή μορφή.';

  @override
  String get addToCloseFriends => 'Προσθήκη στους στενούς φίλους';

  @override
  String maxFriendsReached(Object max, Object added) {
    return 'Όριο $max φίλων: προστέθηκαν $added.';
  }

  @override
  String get add => 'Προσθήκη';

  @override
  String get signInToCreateList => 'Συνδέσου για να φτιάξεις τη λίστα σου.';

  @override
  String get signerNoCloseFriends =>
      'Οι στενοί φίλοι δεν είναι διαθέσιμοι με αυτή τη μέθοδο σύνδεσης. Συνδέσου με Amber, bunker ή το τοπικό κλειδί.';

  @override
  String peopleOfMax(Object count, Object max) {
    return '$count / $max άτομα';
  }

  @override
  String get noOneYet => 'Κανείς ακόμα.';

  @override
  String get addPeople => 'Προσθήκη ατόμων';

  @override
  String get friendNoPrivateMessagesWarning =>
      'Δεν έχουν ενεργοποιήσει ιδιωτικά μηνύματα: δεν θα λαμβάνουν τις αναρτήσεις σου';

  @override
  String get removeFromList => 'Αφαίρεση από τη λίστα';

  @override
  String get noOneWithThisName => 'Κανείς με αυτό το όνομα.';

  @override
  String get signInToSendPrivateContent =>
      'Συνδέσου για να στείλεις ιδιωτικό περιεχόμενο.';

  @override
  String get reasonNoPrivateMessages =>
      'δεν έχει ενεργοποιήσει ιδιωτικά μηνύματα';

  @override
  String get reasonNoRelayAnswered => 'κανένα relay δεν απάντησε';

  @override
  String get profileUpdated => 'Το προφίλ ενημερώθηκε';

  @override
  String get noRelayAcceptedRetry =>
      'Κανένα relay δεν το δέχτηκε. Δοκίμασε ξανά αργότερα.';

  @override
  String get editProfile => 'Επεξεργασία προφίλ';

  @override
  String get fieldName => 'Όνομα';

  @override
  String get fieldBio => 'Bio';

  @override
  String get fieldAvatarUrl => 'URL avatar';

  @override
  String get fieldNip05 => 'NIP-05 (π.χ. you@example.com)';

  @override
  String get browsingAsGuest => 'Περιηγείσαι ως επισκέπτης';

  @override
  String get signInToInteract =>
      'Συνδέσου για να δημοσιεύεις, να ακολουθείς και να αλληλεπιδράς.';

  @override
  String get settings => 'Ρυθμίσεις';

  @override
  String get signOut => 'Αποσύνδεση';

  @override
  String get npubCopied => 'Το npub αντιγράφηκε';

  @override
  String get copyNpub => 'Αντιγραφή npub';

  @override
  String get mute => 'Σίγαση';

  @override
  String get block => 'Αποκλεισμός';

  @override
  String get posts => 'Αναρτήσεις';

  @override
  String get saved => 'Αποθηκευμένα';

  @override
  String get nothingPublishedYet => 'Δεν έχεις δημοσιεύσει τίποτα ακόμα.';

  @override
  String get noPostsOnRelays => 'Δεν βρέθηκαν αναρτήσεις στα relays.';

  @override
  String get noReelsPublished => 'Δεν υπάρχουν δημοσιευμένα reels.';

  @override
  String get noReelsOnRelays => 'Δεν βρέθηκαν reels στα relays.';

  @override
  String get noSavedPosts => 'Δεν υπάρχουν αποθηκευμένες αναρτήσεις.';

  @override
  String get followingButton => 'Ακολουθείς';

  @override
  String get follow => 'Ακολούθησε';

  @override
  String get messageButton => 'Μήνυμα';

  @override
  String get loginLocalKey => 'Τοπικό κλειδί';

  @override
  String get loginGuest => 'Επισκέπτης';

  @override
  String get followUpdateFailed =>
      'Οι ακολουθήσεις σου δεν ενημερώθηκαν τώρα. Δοκίμασε ξανά.';

  @override
  String get noReelsComeBack =>
      'Δεν βρέθηκαν reels στα relays.\nΈλα ξανά σύντομα!';

  @override
  String get followUpdateFailedShort =>
      'Οι ακολουθήσεις σου δεν ενημερώθηκαν τώρα';

  @override
  String get needOneReadRelay => 'Χρειάζεται τουλάχιστον ένα relay ανάγνωσης.';

  @override
  String get listSavedLocally =>
      'Η λίστα αποθηκεύτηκε σε αυτή τη συσκευή, δεν δημοσιεύτηκε.';

  @override
  String get noRelayAcceptedList =>
      'Κανένα relay δεν δέχτηκε τη λίστα: θα ξαναδοκιμαστεί αργότερα.';

  @override
  String relayListPublishedTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Η λίστα Relay δημοσιεύτηκε σε $count relays',
      one: 'Η λίστα Relay δημοσιεύτηκε σε 1 relay',
    );
    return '$_temp0';
  }

  @override
  String get mediaServersUpdated => 'Οι διακομιστές πολυμέσων ενημερώθηκαν';

  @override
  String get appearance => 'Εμφάνιση';

  @override
  String get publishingSettings => 'Δημοσίευση';

  @override
  String get addMialunaHashtag => 'Προσθήκη #mialuna';

  @override
  String get addMialunaHashtagNote =>
      'Πρόσθεσε το επίσημο hashtag σε δημόσιες αναρτήσεις και ιστορίες. Μπορείς να το απενεργοποιήσεις οποιαδήποτε στιγμή.';

  @override
  String get themeLight => 'Ανοιχτό';

  @override
  String get themeDark => 'Σκούρο';

  @override
  String get themeSystem => 'Σύστημα';

  @override
  String get relays => 'Relays';

  @override
  String get relaysExplainSignedOut =>
      'Τα Relays αποθηκεύουν και διανέμουν περιεχόμενο. Συνδέσου για να χρησιμοποιείς αυτόματα τη δική σου λίστα (NIP-65).';

  @override
  String get relaysExplainSynced =>
      'Η λίστα συγχρονίζεται με το προφίλ σου στο Nostr (NIP-65): κάθε αλλαγή δημοσιεύεται και ισχύει σε όλες τις εφαρμογές σου.';

  @override
  String get syncing => 'Συγχρονισμός…';

  @override
  String get waitingFirstSync => 'Αναμονή του πρώτου συγχρονισμού';

  @override
  String get syncNow => 'Συγχρονισμός τώρα';

  @override
  String get addRelay => 'Προσθήκη relay';

  @override
  String get restoreDefaultRelays => 'Επαναφορά προεπιλεγμένων relays';

  @override
  String get createYourList => 'Φτιάξε τη λίστα σου';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count άτομα',
      one: '1 άτομο',
    );
    return '$_temp0';
  }

  @override
  String get closeFriendsSettingsNote =>
      'Αναρτήσεις, ιστορίες και βίντεο ορατά μόνο σε αυτούς, με κρυπτογραφημένες φωτογραφίες και βίντεο.';

  @override
  String get mediaServersBlossom => 'Διακομιστές πολυμέσων (Blossom)';

  @override
  String get mediaServersExplain =>
      'Φωτογραφίες και βίντεο ανεβαίνουν μόνο σε αυτούς τους διακομιστές, με τη σειρά που φαίνεται: κερδίζει ο πρώτος που τα δέχεται. Τα EXIF και η τοποθεσία αφαιρούνται πριν το ανέβασμα.';

  @override
  String get primary => 'Κύριο';

  @override
  String get makePrimary => 'Κάνε το κύριο';

  @override
  String get remove => 'Αφαίρεση';

  @override
  String get addServer => 'Προσθήκη διακομιστή';

  @override
  String get moderation => 'Εποπτεία';

  @override
  String get moderationExplain =>
      'Οι συντάκτες σε σίγαση και τα κρυμμένα hashtag συγχρονίζονται μέσω NIP-51. Οι αποκλεισμένοι συντάκτες μένουν μόνο σε αυτή τη συσκευή.';

  @override
  String get mutedAuthors => 'Συντάκτες σε σίγαση';

  @override
  String get noMutedAuthors => 'Κανένας συντάκτης σε σίγαση';

  @override
  String get blockedAuthors => 'Αποκλεισμένοι συντάκτες';

  @override
  String get noBlockedAuthors => 'Κανένας αποκλεισμένος συντάκτης';

  @override
  String get hiddenHashtags => 'Κρυμμένα hashtag';

  @override
  String get noHiddenHashtags => 'Κανένα κρυμμένο hashtag';

  @override
  String get hashtagToHide => '#hashtag για απόκρυψη';

  @override
  String get storage => 'Αποθήκευση';

  @override
  String get clearCache =>
      'Εκκαθάριση προσωρινής μνήμης συμβάντων και προσχεδίων';

  @override
  String get cacheCleared => 'Η προσωρινή μνήμη καθάρισε';

  @override
  String get reviewIntro => 'Δες ξανά την εισαγωγή';

  @override
  String get reviewIntroSubtitle =>
      'Τι είναι δημόσιο, τι ιδιωτικό και τα όρια των στενών φίλων.';

  @override
  String noLightningWalletCopied(Object address) {
    return 'Δεν βρέθηκε πορτοφόλι Lightning: η διεύθυνση αντιγράφηκε ($address)';
  }

  @override
  String get about => 'Σχετικά';

  @override
  String aboutText(Object version) {
    return 'Mialuna $version — Οι στιγμές σου, κάτω από το ίδιο φεγγάρι.\nΑνοιχτός κώδικας (MIT). github.com/Lwb89dev/mialuna';
  }

  @override
  String get invalidRelayAddress =>
      'Μη έγκυρη διεύθυνση: χρησιμοποίησε wss://…';

  @override
  String get invalidServerAddress =>
      'Μη έγκυρη διεύθυνση: χρησιμοποίησε https://…';

  @override
  String get relayRead => 'Ανάγνωση';

  @override
  String get relayWrite => 'Εγγραφή';

  @override
  String get support => 'Υποστήριξη';

  @override
  String get supportText =>
      'Η Mialuna είναι δωρεάν, χωρίς διαφημίσεις και δεν σε παρακολουθεί. Αν σου αρέσει, μπορείς να στείλεις λίγα sats στο δίκτυο Lightning.';

  @override
  String get donateWithLightning => 'Δωρεά μέσω Lightning';

  @override
  String get authorNoZaps => 'Αυτός ο συντάκτης δεν δέχεται zaps';

  @override
  String get sendZap => 'Αποστολή zap ⚡';

  @override
  String get amountInSats => 'Ποσό σε sats';

  @override
  String minMaxSats(Object min, Object max) {
    return 'ελάχ. $min – μέγ. $max';
  }

  @override
  String get zap => 'Zap';

  @override
  String get signInToZap => 'Συνδέσου για αποστολή zaps';

  @override
  String zapSent(Object sats) {
    return 'Στάλθηκε Zap $sats sats ⚡';
  }

  @override
  String nwcPaymentFailed(Object error) {
    return 'Η πληρωμή NWC απέτυχε: $error';
  }

  @override
  String get noLightningWallet => 'Δεν βρέθηκε πορτοφόλι Lightning';

  @override
  String storiesRailLabel(Object state) {
    return 'Ιστορίες, $state';
  }

  @override
  String get close => 'Κλείσιμο';

  @override
  String hoursAgo(int hours) {
    return 'πριν $hours ώ';
  }

  @override
  String daysAgo(int days) {
    return 'πριν $days ημ';
  }

  @override
  String get now => 'τώρα';

  @override
  String get youPrefix => 'Εσύ: ';

  @override
  String get storiesStateUnseen => 'νέα';

  @override
  String get storiesStateSeen => 'ιδωμένη';

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Δευ',
      'tue': 'Τρί',
      'wed': 'Τετ',
      'thu': 'Πέμ',
      'fri': 'Παρ',
      'sat': 'Σάβ',
      'sun': 'Κυρ',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sharedAMoment => 'Μοιράστηκε μια στιγμή';

  @override
  String get blossomOtherError => 'σφάλμα';

  @override
  String get languageTitle => 'Γλώσσα';

  @override
  String get languageSystem => 'Σύστημα';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get cannotEditPhoto => 'Αυτή η φωτογραφία δεν επεξεργάζεται εδώ.';

  @override
  String notificationsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count νέες ειδοποιήσεις',
      one: '1 νέα ειδοποίηση',
    );
    return '$_temp0';
  }

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count μη αναγνωσμένα μηνύματα',
      one: '1 μη αναγνωσμένο μήνυμα',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Έτοιμο';

  @override
  String get storyAddText => 'Προσθήκη κειμένου';

  @override
  String get storyEditText => 'Επεξεργασία κειμένου';

  @override
  String get storyTextHint => 'Γράψε κάτι… τα #hashtags πατιούνται';

  @override
  String get storyTextsHelp =>
      'Πάτα την εικόνα για να γράψεις. Σύρε για μετακίνηση, τσίμπησε για μέγεθος και περιστροφή, πάτα ένα κείμενο για επεξεργασία.';

  @override
  String storyTextsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count κείμενα',
      one: '1 κείμενο',
      zero: 'Χωρίς κείμενο',
    );
    return '$_temp0';
  }

  @override
  String get storyFontClassic => 'Κλασική';

  @override
  String get storyFontBold => 'Έντονη';

  @override
  String get storyFontSerif => 'Serif';

  @override
  String get storyFontMono => 'Mono';

  @override
  String get storyFontItalic => 'Πλάγια';

  @override
  String get storyTextBackground => 'Φόντο κειμένου';

  @override
  String get storyTextColor => 'Χρώμα κειμένου';

  @override
  String storyTextLimit(int max) {
    return 'Μπορείς να προσθέσεις έως $max κείμενα.';
  }

  @override
  String get wotTitle => 'Δίκτυο εμπιστοσύνης';

  @override
  String get wotEnable => 'Το δίκτυο εμπιστοσύνης είναι πάντα ενεργό';

  @override
  String wotExplain(int min) {
    return 'Πάντα ενεργό. Η Ανακάλυψη δείχνει μόνο αυτό το δίκτυο: εσύ, όσοι ακολουθείς και όποιος ακολουθείται από τουλάχιστον $min από αυτούς. Το ίδιο δίκτυο κρύβει σχόλια, ειδοποιήσεις, ιδιωτικές αναρτήσεις και μηνύματα όλων των άλλων. Υπολογίζεται σε αυτό το τηλέφωνο από δημόσιες λίστες ακολουθίας την πρώτη φορά που ανοίγεις την εφαρμογή. Μετά το ξαναχρησιμοποιεί. Τίποτα δεν στέλνεται σε κανέναν διακομιστή.';
  }

  @override
  String get wotRefresh => 'Ανανέωση δικτύου τώρα';

  @override
  String get wotStatusIdle =>
      'Δεν έχει δημιουργηθεί ακόμα. Δημιουργείται την πρώτη φορά που ανοίγεις την εφαρμογή.';

  @override
  String get wotBuildingTitle => 'Δημιουργία της ροής Ανακάλυψη';

  @override
  String get wotBuildingBody =>
      'Διαβάζουμε ποιους ακολουθούν όσοι ακολουθείς και ετοιμάζουμε την Ανακάλυψη.';

  @override
  String get wotDiscoverHint =>
      'Μόνο το δίκτυο εμπιστοσύνης σου: άτομα που ακολουθείς και άτομα που ακολουθούν αρκετοί από αυτούς.';

  @override
  String get wotDiscoverSignIn =>
      'Η Ανακάλυψη δείχνει το δίκτυο εμπιστοσύνης σου. Συνδέσου και, την πρώτη φορά, η Mialuna διαβάζει ποιους ακολουθείς και φτιάχνει αυτή τη ροή. Μετά την ξαναχρησιμοποιεί.';

  @override
  String get wotDiscoverEmpty =>
      'Καμία ανάρτηση από το δίκτυο εμπιστοσύνης σου ακόμα.';

  @override
  String wotStatusDiscovering(int done, int total) {
    return 'Έλεγχος ποιους ακολουθούν οι ακολουθήσεις σου… $done από $total';
  }

  @override
  String wotStatusComplete(int direct, int indirect, Object when) {
    return 'Το δίκτυό σου: $direct άτομα που ακολουθείς συν $indirect που ακολουθούνται από αρκετούς. Ενημέρωση $when.';
  }

  @override
  String wotStatusFailed(Object reason) {
    return 'Δεν υπολογίστηκε το δίκτυό σου: $reason';
  }

  @override
  String get wotNoFollows => 'δεν ακολουθείς κανέναν ακόμα';

  @override
  String get messageRequests => 'Αιτήματα μηνυμάτων';

  @override
  String messageRequestsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count συνομιλίες έξω από το δίκτυο εμπιστοσύνης σου',
      one: '1 συνομιλία έξω από το δίκτυο εμπιστοσύνης σου',
    );
    return '$_temp0';
  }

  @override
  String get messageRequestsHint =>
      'Από άτομα έξω από το δίκτυο εμπιστοσύνης σου. Δεν μετρούν ως μη αναγνωσμένα. Απάντησε για να πάει η συνομιλία στα εισερχόμενα.';

  @override
  String get storyViewsSetting => 'Να βλέπουν ότι είδα τις ιστορίες τους';

  @override
  String get storyViewsSettingExplain =>
      'Όταν βλέπεις μια ιστορία, στέλνεται απόδειξη στον συντάκτη, κρυπτογραφημένη ώστε μόνο εκείνος να τη διαβάζει. Αναφέρει το όνομά σου δίπλα στο δικό του. Τα relays δεν βλέπουν τίποτα. Αν δεν παραδοθεί, κρατιέται και δοκιμάζεται αργότερα. Απενεργοποίησέ το για να βλέπεις χωρίς να το μάθει κανείς: αποδείξεις που δεν στάλθηκαν ακόμα απορρίπτονται (όσες παραδόθηκαν δεν γυρίζουν πίσω).';

  @override
  String storySeenBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Το είδαν $count άτομα',
      one: 'Το είδε 1 άτομο',
      zero: 'Καμία προβολή ακόμα',
    );
    return '$_temp0';
  }

  @override
  String get storyViewsEmpty =>
      'Κανείς δεν έχει δει ακόμα αυτή την ιστορία, ή οι αποδείξεις δεν σου έχουν φτάσει.';

  @override
  String get storyViewsHint =>
      'Μόνο όσοι το επιτρέπουν στέλνουν απόδειξη, άρα ο πραγματικός αριθμός μπορεί να είναι μεγαλύτερος.';

  @override
  String get systemNotifications => 'Ειδοποιήσεις συστήματος';

  @override
  String get systemNotificationsExplain =>
      'Δείξε ειδοποίηση στο τηλέφωνο όταν φτάνει κάτι νέο ενώ η Mialuna είναι στο παρασκήνιο. Τα ιδιωτικά μηνύματα δεν δείχνουν ποτέ το κείμενό τους, ούτε στην οθόνη κλειδώματος. Το Android σταματά εφαρμογές που μένουν πολλή ώρα στο παρασκήνιο, οπότε οι ειδοποιήσεις φτάνουν όσο η Mialuna ακόμα εκτελείται.';

  @override
  String get systemNotificationsBlocked =>
      'Οι ειδοποιήσεις για τη Mialuna είναι κλειστές στις ρυθμίσεις του τηλεφώνου.';

  @override
  String get systemNotificationsOpenSettings => 'Άνοιγμα ρυθμίσεων';

  @override
  String get systemNotificationsBattery =>
      'Το Android κοιμίζει τις εφαρμογές λίγα λεπτά αφού σβήσει η οθόνη και οι ειδοποιήσεις σταματούν μαζί τους. Για να συνεχίσεις να τις παίρνεις, όρισε τη χρήση μπαταρίας της Mialuna σε “Unrestricted”.';

  @override
  String get systemNotificationsBatteryAction => 'Άνοιγμα ρυθμίσεων μπαταρίας';

  @override
  String get newFollowersSetting => 'Εμφάνιση νέων ακόλουθων';

  @override
  String get newFollowersSettingExplain =>
      'Οι νέοι ακόλουθοι φαίνονται στις Ειδοποιήσεις και στο τηλέφωνό σου. Απενεργοποίησέ το αν σε πλημμυρίζουν ακολουθήσεις: τα like, τα σχόλια και τα zaps συνεχίζουν να φαίνονται.';

  @override
  String get systemNotificationMessage => 'σου έστειλε ιδιωτικό μήνυμα';

  @override
  String get systemNotificationNewMessage => 'Νέο ιδιωτικό μήνυμα';

  @override
  String get systemNotificationNew => 'Νέα ειδοποίηση';

  @override
  String get notificationChannelSocial =>
      'Αντιδράσεις, σχόλια, zaps και ακόλουθοι';

  @override
  String get notificationChannelMessages => 'Ιδιωτικά μηνύματα';

  @override
  String get zapInvoiceMismatch =>
      'Το τιμολόγιο δεν ταιριάζει με το ποσό που διάλεξες. Δεν πληρώθηκε τίποτα.';

  @override
  String get storyYourStory => 'Η ιστορία σου';

  @override
  String get storyNew => 'Νέα ιστορία';

  @override
  String get storyAddSemantics => 'Προσθήκη στην ιστορία σου';

  @override
  String storyOwnRailLabel(int count, Object state) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ιστορίες',
      one: '1 ιστορία',
    );
    return 'Η ιστορία σου, $_temp0, $state';
  }

  @override
  String get storyTextSize => 'Μέγεθος κειμένου';

  @override
  String get storyPickPrompt =>
      'Διάλεξε φωτογραφία ή βίντεο για την ιστορία σου';

  @override
  String get storyEditPhoto => 'Επεξεργασία φωτογραφίας';

  @override
  String get storyCaption => 'Λεζάντα';

  @override
  String get storyDiscardTitle => 'Απόρριψη αυτής της ιστορίας;';

  @override
  String get storyDiscard => 'Απόρριψη';

  @override
  String get storyShare => 'Κοινοποίηση';

  @override
  String get storyShared => 'Η ιστορία κοινοποιήθηκε';

  @override
  String get deletePost => 'Διαγραφή';

  @override
  String get deletePostTitle => 'Διαγραφή αυτής της ανάρτησης;';

  @override
  String get deleteStoryTitle => 'Διαγραφή αυτής της ιστορίας;';

  @override
  String get deletePostBody =>
      'Η Mialuna θα ζητήσει από τα relays να τη διαγράψουν και από τους διακομιστές πολυμέσων να διαγράψουν τις φωτογραφίες ή το βίντεο. Ένα relay που αγνοεί το αίτημα, ή κάποιος που κράτησε ήδη αντίγραφο, μπορεί ακόμα να την έχει.';

  @override
  String get deletePrivateBody =>
      'Ανάρτηση στενών φίλων δεν ανακαλείται από τα relays. Η Mialuna θα πει στις εφαρμογές των φίλων σου να την αφαιρέσουν και θα ζητήσει από τον διακομιστή πολυμέσων να διαγράψει τα κρυπτογραφημένα αρχεία. Φίλος που έχει ήδη κρατήσει αντίγραφο μπορεί ακόμα να το έχει.';

  @override
  String get deletingPost => 'Διαγραφή…';

  @override
  String get postDeleted => 'Διαγράφηκε.';

  @override
  String get postWasDeleted => 'Αυτή η ανάρτηση διαγράφηκε.';

  @override
  String get deleteNotAllowed =>
      'Μόνο ο λογαριασμός που το δημοσίευσε μπορεί να το διαγράψει.';

  @override
  String deleteFailed(Object reason) {
    return 'Αποτυχία διαγραφής: $reason';
  }

  @override
  String get deleteNoRelay =>
      'Κανένα relay δεν δέχτηκε το αίτημα διαγραφής, οπότε μένει ακόμα online. Έλεγξε τη σύνδεση και δοκίμασε ξανά.';

  @override
  String deleteMediaLeft(Object servers) {
    return 'Τα πολυμέσα δεν αφαιρέθηκαν από $servers.';
  }

  @override
  String get deleteMediaNotAuthorized =>
      'Ο υπογράφων σου δεν εξουσιοδότησε την αφαίρεση των πολυμέσων, οπότε τα αρχεία μένουν στον διακομιστή πολυμέσων.';

  @override
  String deleteFriendsMissed(Object count) {
    return 'Δεν ενημερώθηκαν $count στενοί φίλοι σου, οπότε μπορεί να μείνει στα τηλέφωνά τους.';
  }

  @override
  String get storyCleanupSetting => 'Διαγραφή των ιστοριών μου όταν λήγουν';

  @override
  String get storyCleanupSettingExplain =>
      'Μετά από 24 ώρες η Mialuna ζητά από τα relays σου και τους διακομιστές πολυμέσων να διαγράψουν τις ιστορίες σου, μαζί με φωτογραφίες και βίντεο. Διακομιστής που αγνοεί το αίτημα, ή κάποιος που κράτησε αντίγραφο, μπορεί ακόμα να τις έχει.';

  @override
  String storyCleanupWaiting(Object count) {
    return 'Ο υπογράφων σου πρέπει να εγκρίνει κάθε καθαρισμό, για αυτό περιμένει μέχρι να το ζητήσεις. Ληγμένες ιστορίες σε αναμονή: $count.';
  }

  @override
  String get storyCleanupNow => 'Διαγραφή τώρα';

  @override
  String get storyCleanupDone => 'Οι ληγμένες ιστορίες διαγράφηκαν.';

  @override
  String get storyCleanupPartly =>
      'Κάποιες δεν διαγράφηκαν ακόμα. Η Mialuna θα ξαναπροσπαθήσει.';
}
