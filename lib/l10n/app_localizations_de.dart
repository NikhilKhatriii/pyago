// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Pyago';

  @override
  String get appTagline => 'Ein ruhiger Ort für das, was du zu sagen hast.';

  @override
  String get navHome => 'Start';

  @override
  String get navExplore => 'Entdecken';

  @override
  String get navCreate => 'Erstellen';

  @override
  String get navCommunities => 'Communities';

  @override
  String get navProfile => 'Profil';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get actionPublish => 'Veröffentlichen';

  @override
  String get actionSignIn => 'Anmelden';

  @override
  String get actionSignOut => 'Abmelden';

  @override
  String get actionSend => 'Senden';

  @override
  String get actionShowMore => 'Mehr anzeigen';

  @override
  String get actionUnlock => 'Entsperren';

  @override
  String get feedTitleToday => 'Für heute';

  @override
  String get feedSeeAll => 'Alle ansehen';

  @override
  String get feedCaughtUpTitle => 'Du bist für heute auf dem Laufenden';

  @override
  String get feedCaughtUpBody =>
      'Pyago zeigt absichtlich nur wenig auf einmal. Morgen gibt es hier mehr.';

  @override
  String get feedCaughtUpLoadAnyway => 'Trotzdem etwas mehr anzeigen';

  @override
  String get feedEmptyTitle => 'Noch nichts kuratiert';

  @override
  String get feedEmptyBody =>
      'Folge ein paar Autor:innen oder Communities, dann füllt sich dieser Bereich.';

  @override
  String get offlineBanner =>
      'Du bist offline — gespeicherte Inhalte werden angezeigt.';

  @override
  String get willPublishWhenOnline =>
      'Wird veröffentlicht, sobald du wieder online bist';

  @override
  String get commentsEmptyTitle => 'Noch keine Gedanken';

  @override
  String get commentsEmptyBody =>
      'Teile als Erste:r, was dieser Text bei dir ausgelöst hat.';

  @override
  String get commentsHint => 'Einen Gedanken teilen…';

  @override
  String get chatEmptyTitle => 'Noch keine Unterhaltungen';

  @override
  String get chatEmptyBody =>
      'Starte eine Unterhaltung über das Profil einer Person.';

  @override
  String get chatMessageHint => 'Nachricht…';

  @override
  String chatIsTyping(Object name) {
    return '$name schreibt gerade…';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAppearance => 'Erscheinungsbild';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsHighContrast => 'Hoher Kontrast';

  @override
  String get settingsTextSize => 'Textgröße';

  @override
  String get settingsLanguage => 'App-Sprache';

  @override
  String get settingsAppLock => 'App-Sperre';

  @override
  String get settingsAppLockSubtitleOn =>
      'Biometrie oder Geräte-PIN erforderlich, um Pyago zu öffnen';

  @override
  String get settingsAppLockSubtitleUnsupported =>
      'Auf diesem Gerät nicht verfügbar';

  @override
  String get appLockScreenTitle => 'Pyago ist gesperrt';

  @override
  String get appLockScreenBody =>
      'Entsperre mit Biometrie oder deiner Geräte-PIN, um fortzufahren.';

  @override
  String get errorGeneric => 'Etwas ist unerwartet schiefgelaufen.';

  @override
  String get errorOffline =>
      'Du bist offline. Gespeicherte Inhalte werden angezeigt.';

  @override
  String get errorTimeout =>
      'Das hat zu lange gedauert. Bitte versuche es erneut.';

  @override
  String get errorServer =>
      'Pyago hat gerade Probleme. Bitte versuche es erneut.';

  @override
  String get errorSessionExpired =>
      'Deine Sitzung ist abgelaufen. Bitte melde dich erneut an.';

  @override
  String get draftsEmptyTitle => 'Keine Entwürfe gespeichert';

  @override
  String get draftsEmptyBody =>
      'Alles, was du zu schreiben beginnst und speicherst, erscheint hier — auch offline.';

  @override
  String get draftsStartWriting => 'Mit dem Schreiben beginnen';

  @override
  String get bookmarksEmptyTitle => 'Noch keine Lesezeichen';

  @override
  String get bookmarksEmptyBody =>
      'Tippe auf das Lesezeichen-Symbol bei allem, worauf du zurückkommen möchtest — auch offline verfügbar.';
}
