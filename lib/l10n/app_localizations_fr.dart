// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Pyago';

  @override
  String get appTagline => 'Un endroit calme pour ce que vous avez à dire.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navExplore => 'Explorer';

  @override
  String get navCreate => 'Créer';

  @override
  String get navCommunities => 'Communautés';

  @override
  String get navProfile => 'Profil';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionPublish => 'Publier';

  @override
  String get actionSignIn => 'Se connecter';

  @override
  String get actionSignOut => 'Se déconnecter';

  @override
  String get actionSend => 'Envoyer';

  @override
  String get actionShowMore => 'Voir plus';

  @override
  String get actionUnlock => 'Déverrouiller';

  @override
  String get feedTitleToday => 'Pour aujourd\'hui';

  @override
  String get feedSeeAll => 'Tout voir';

  @override
  String get feedCaughtUpTitle => 'Vous êtes à jour pour aujourd\'hui';

  @override
  String get feedCaughtUpBody =>
      'Pyago affiche volontairement peu de contenu à la fois. Il y en aura plus demain.';

  @override
  String get feedCaughtUpLoadAnyway => 'Afficher un peu plus quand même';

  @override
  String get feedEmptyTitle => 'Rien n\'a encore été sélectionné';

  @override
  String get feedEmptyBody =>
      'Suivez quelques auteurs ou communautés, cet espace commencera à se remplir.';

  @override
  String get offlineBanner =>
      'Vous êtes hors ligne — contenu enregistré affiché.';

  @override
  String get willPublishWhenOnline =>
      'Sera publié dès que vous serez de nouveau en ligne';

  @override
  String get commentsEmptyTitle => 'Aucune réaction pour l\'instant';

  @override
  String get commentsEmptyBody =>
      'Soyez le premier à partager ce que ce texte vous a inspiré.';

  @override
  String get commentsHint => 'Partagez une pensée…';

  @override
  String get chatEmptyTitle => 'Aucune conversation pour l\'instant';

  @override
  String get chatEmptyBody =>
      'Démarrez une conversation depuis le profil de quelqu\'un.';

  @override
  String get chatMessageHint => 'Message…';

  @override
  String chatIsTyping(Object name) {
    return '$name est en train d\'écrire…';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsHighContrast => 'Contraste élevé';

  @override
  String get settingsTextSize => 'Taille du texte';

  @override
  String get settingsLanguage => 'Langue de l\'application';

  @override
  String get settingsAppLock => 'Verrouillage de l\'application';

  @override
  String get settingsAppLockSubtitleOn =>
      'Biométrie ou code PIN de l\'appareil requis pour ouvrir Pyago';

  @override
  String get settingsAppLockSubtitleUnsupported =>
      'Non disponible sur cet appareil';

  @override
  String get appLockScreenTitle => 'Pyago est verrouillé';

  @override
  String get appLockScreenBody =>
      'Déverrouillez avec la biométrie ou le code PIN de votre appareil pour continuer.';

  @override
  String get errorGeneric => 'Une erreur inattendue s\'est produite.';

  @override
  String get errorOffline =>
      'Vous êtes hors ligne. Contenu enregistré affiché.';

  @override
  String get errorTimeout => 'Cela a pris trop de temps. Veuillez réessayer.';

  @override
  String get errorServer =>
      'Pyago rencontre des difficultés en ce moment. Veuillez réessayer.';

  @override
  String get errorSessionExpired =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get draftsEmptyTitle => 'Aucun brouillon enregistré';

  @override
  String get draftsEmptyBody =>
      'Tout ce que vous commencez à écrire et enregistrez apparaîtra ici — même hors ligne.';

  @override
  String get draftsStartWriting => 'Commencer à écrire';

  @override
  String get bookmarksEmptyTitle => 'Aucun favori pour l\'instant';

  @override
  String get bookmarksEmptyBody =>
      'Appuyez sur l\'icône favori pour tout ce à quoi vous voulez revenir — disponible aussi hors ligne.';
}
