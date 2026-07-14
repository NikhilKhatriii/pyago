// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Pyago';

  @override
  String get appTagline => 'あなたの言葉のための静かな場所。';

  @override
  String get navHome => 'ホーム';

  @override
  String get navExplore => '見つける';

  @override
  String get navCreate => '作成';

  @override
  String get navCommunities => 'コミュニティ';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionSave => '保存';

  @override
  String get actionRetry => '再試行';

  @override
  String get actionPublish => '公開する';

  @override
  String get actionSignIn => 'サインイン';

  @override
  String get actionSignOut => 'サインアウト';

  @override
  String get actionSend => '送信';

  @override
  String get actionShowMore => 'もっと見る';

  @override
  String get actionUnlock => 'ロック解除';

  @override
  String get feedTitleToday => '今日のおすすめ';

  @override
  String get feedSeeAll => 'すべて見る';

  @override
  String get feedCaughtUpTitle => '今日はここまでです';

  @override
  String get feedCaughtUpBody => 'Pyagoはあえて少しずつ表示しています。続きはまた明日。';

  @override
  String get feedCaughtUpLoadAnyway => 'それでももう少し見る';

  @override
  String get feedEmptyTitle => 'まだ表示できる投稿がありません';

  @override
  String get feedEmptyBody => '作家やコミュニティをフォローすると、ここが少しずつ埋まっていきます。';

  @override
  String get offlineBanner => 'オフラインです — 保存済みの内容を表示しています。';

  @override
  String get willPublishWhenOnline => 'オンラインに戻ったら公開されます';

  @override
  String get commentsEmptyTitle => 'まだ感想がありません';

  @override
  String get commentsEmptyBody => 'この作品から感じたことを、最初にシェアしてみませんか。';

  @override
  String get commentsHint => '感想を書く…';

  @override
  String get chatEmptyTitle => '会話はまだありません';

  @override
  String get chatEmptyBody => '誰かのプロフィールから会話を始めましょう。';

  @override
  String get chatMessageHint => 'メッセージ…';

  @override
  String chatIsTyping(Object name) {
    return '$nameさんが入力中…';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAppearance => '外観';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get settingsHighContrast => 'ハイコントラスト';

  @override
  String get settingsTextSize => '文字サイズ';

  @override
  String get settingsLanguage => 'アプリの言語';

  @override
  String get settingsAppLock => 'アプリロック';

  @override
  String get settingsAppLockSubtitleOn => 'Pyagoを開くには生体認証または端末のPINが必要です';

  @override
  String get settingsAppLockSubtitleUnsupported => 'この端末では利用できません';

  @override
  String get appLockScreenTitle => 'Pyagoはロックされています';

  @override
  String get appLockScreenBody => '続けるには生体認証または端末のPINでロックを解除してください。';

  @override
  String get errorGeneric => '予期しない問題が発生しました。';

  @override
  String get errorOffline => 'オフラインです。保存済みの内容を表示しています。';

  @override
  String get errorTimeout => '時間がかかりすぎました。もう一度お試しください。';

  @override
  String get errorServer => 'Pyagoに一時的な問題が発生しています。もう一度お試しください。';

  @override
  String get errorSessionExpired => 'セッションの有効期限が切れました。再度サインインしてください。';

  @override
  String get draftsEmptyTitle => '保存された下書きはありません';

  @override
  String get draftsEmptyBody => '書き始めて保存したものはここに表示されます — オフラインでも。';

  @override
  String get draftsStartWriting => '書き始める';

  @override
  String get bookmarksEmptyTitle => 'まだブックマークがありません';

  @override
  String get bookmarksEmptyBody =>
      'また戻ってきたいものにブックマークアイコンをタップしてください — オフラインでも利用できます。';
}
