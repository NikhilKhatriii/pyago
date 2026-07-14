// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'प्यागो';

  @override
  String get appTagline => 'आपकी बात कहने के लिए एक शांत जगह।';

  @override
  String get navHome => 'होम';

  @override
  String get navExplore => 'एक्सप्लोर';

  @override
  String get navCreate => 'बनाएँ';

  @override
  String get navCommunities => 'समुदाय';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get actionCancel => 'रद्द करें';

  @override
  String get actionSave => 'सहेजें';

  @override
  String get actionRetry => 'पुनः प्रयास करें';

  @override
  String get actionPublish => 'प्रकाशित करें';

  @override
  String get actionSignIn => 'साइन इन करें';

  @override
  String get actionSignOut => 'साइन आउट करें';

  @override
  String get actionSend => 'भेजें';

  @override
  String get actionShowMore => 'और दिखाएँ';

  @override
  String get actionUnlock => 'अनलॉक करें';

  @override
  String get feedTitleToday => 'आज के लिए';

  @override
  String get feedSeeAll => 'सभी देखें';

  @override
  String get feedCaughtUpTitle => 'आप आज के लिए अपडेट हैं';

  @override
  String get feedCaughtUpBody =>
      'प्यागो जानबूझकर थोड़ा-थोड़ा दिखाता है। कल और सामग्री यहाँ होगी।';

  @override
  String get feedCaughtUpLoadAnyway => 'फिर भी थोड़ा और दिखाएँ';

  @override
  String get feedEmptyTitle => 'अभी तक कुछ भी क्यूरेट नहीं किया गया';

  @override
  String get feedEmptyBody =>
      'कुछ लेखकों या समुदायों को फॉलो करें, यह जगह भरने लगेगी।';

  @override
  String get offlineBanner =>
      'आप ऑफ़लाइन हैं — सहेजी गई सामग्री दिखाई जा रही है।';

  @override
  String get willPublishWhenOnline => 'फिर से ऑनलाइन होने पर प्रकाशित होगा';

  @override
  String get commentsEmptyTitle => 'अभी तक कोई विचार नहीं';

  @override
  String get commentsEmptyBody =>
      'इस लेख ने आपके मन में क्या ख्याल जगाया, सबसे पहले साझा करें।';

  @override
  String get commentsHint => 'एक विचार साझा करें…';

  @override
  String get chatEmptyTitle => 'अभी तक कोई बातचीत नहीं';

  @override
  String get chatEmptyBody => 'किसी की प्रोफ़ाइल से बातचीत शुरू करें।';

  @override
  String get chatMessageHint => 'संदेश…';

  @override
  String chatIsTyping(Object name) {
    return '$name टाइप कर रहे हैं…';
  }

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsAppearance => 'दिखावट';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsHighContrast => 'उच्च कंट्रास्ट';

  @override
  String get settingsTextSize => 'टेक्स्ट आकार';

  @override
  String get settingsLanguage => 'ऐप की भाषा';

  @override
  String get settingsAppLock => 'ऐप लॉक';

  @override
  String get settingsAppLockSubtitleOn =>
      'प्यागो खोलने के लिए बायोमेट्रिक्स या डिवाइस पिन आवश्यक';

  @override
  String get settingsAppLockSubtitleUnsupported =>
      'इस डिवाइस पर उपलब्ध नहीं है';

  @override
  String get appLockScreenTitle => 'प्यागो लॉक है';

  @override
  String get appLockScreenBody =>
      'जारी रखने के लिए बायोमेट्रिक्स या अपने डिवाइस पिन से अनलॉक करें।';

  @override
  String get errorGeneric => 'कुछ अप्रत्याशित हुआ।';

  @override
  String get errorOffline =>
      'आप ऑफ़लाइन हैं। सहेजी गई सामग्री दिखाई जा रही है।';

  @override
  String get errorTimeout => 'इसमें बहुत समय लग गया। कृपया फिर से प्रयास करें।';

  @override
  String get errorServer =>
      'प्यागो को अभी परेशानी हो रही है। कृपया फिर से प्रयास करें।';

  @override
  String get errorSessionExpired =>
      'आपका सत्र समाप्त हो गया है। कृपया फिर से साइन इन करें।';

  @override
  String get draftsEmptyTitle => 'कोई ड्राफ़्ट सहेजा नहीं गया';

  @override
  String get draftsEmptyBody =>
      'आपने जो कुछ भी लिखना शुरू करके सहेजा है, वह यहाँ दिखेगा — ऑफ़लाइन होने पर भी।';

  @override
  String get draftsStartWriting => 'लिखना शुरू करें';

  @override
  String get bookmarksEmptyTitle => 'अभी तक कोई बुकमार्क नहीं';

  @override
  String get bookmarksEmptyBody =>
      'जिस चीज़ पर वापस आना चाहते हैं उस पर बुकमार्क आइकन टैप करें — ऑफ़लाइन में भी उपलब्ध।';
}
