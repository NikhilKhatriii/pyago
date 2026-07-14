// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pyago';

  @override
  String get appTagline => 'A quiet place for what you have to say.';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navCreate => 'Create';

  @override
  String get navCommunities => 'Communities';

  @override
  String get navProfile => 'Profile';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionPublish => 'Publish';

  @override
  String get actionSignIn => 'Sign in';

  @override
  String get actionSignOut => 'Sign out';

  @override
  String get actionSend => 'Send';

  @override
  String get actionShowMore => 'Show more';

  @override
  String get actionUnlock => 'Unlock';

  @override
  String get feedTitleToday => 'For today';

  @override
  String get feedSeeAll => 'See all';

  @override
  String get feedCaughtUpTitle => 'You\'re caught up for today';

  @override
  String get feedCaughtUpBody =>
      'Pyago shows a little at a time on purpose. More will be here tomorrow.';

  @override
  String get feedCaughtUpLoadAnyway => 'Show a bit more anyway';

  @override
  String get feedEmptyTitle => 'Nothing curated yet';

  @override
  String get feedEmptyBody =>
      'Follow a few writers or communities and this space will start to fill up.';

  @override
  String get offlineBanner => 'You\'re offline — showing saved content.';

  @override
  String get willPublishWhenOnline => 'Will publish when you\'re back online';

  @override
  String get commentsEmptyTitle => 'No thoughts yet';

  @override
  String get commentsEmptyBody =>
      'Be the first to share what this piece brought up for you.';

  @override
  String get commentsHint => 'Share a thought…';

  @override
  String get chatEmptyTitle => 'No conversations yet';

  @override
  String get chatEmptyBody => 'Start a conversation from someone\'s profile.';

  @override
  String get chatMessageHint => 'Message…';

  @override
  String chatIsTyping(Object name) {
    return '$name is typing…';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsHighContrast => 'High contrast';

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get settingsLanguage => 'App language';

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsAppLockSubtitleOn =>
      'Require biometrics or device PIN to open Pyago';

  @override
  String get settingsAppLockSubtitleUnsupported =>
      'Not available on this device';

  @override
  String get appLockScreenTitle => 'Pyago is locked';

  @override
  String get appLockScreenBody =>
      'Unlock with biometrics or your device PIN to continue.';

  @override
  String get errorGeneric => 'Something unexpected happened.';

  @override
  String get errorOffline => 'You\'re offline. Showing saved content.';

  @override
  String get errorTimeout => 'That took too long. Please try again.';

  @override
  String get errorServer =>
      'Pyago is having trouble right now. Please try again.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get draftsEmptyTitle => 'No drafts saved';

  @override
  String get draftsEmptyBody =>
      'Anything you start writing and save will show up here — even offline.';

  @override
  String get draftsStartWriting => 'Start writing';

  @override
  String get bookmarksEmptyTitle => 'No bookmarks yet';

  @override
  String get bookmarksEmptyBody =>
      'Tap the bookmark icon on anything you want to come back to — available offline too.';
}
