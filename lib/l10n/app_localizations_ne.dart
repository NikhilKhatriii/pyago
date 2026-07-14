// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appName => 'प्यागो';

  @override
  String get appTagline => 'तपाईंले भन्न चाहनुभएको कुराको लागि एक शान्त ठाउँ।';

  @override
  String get navHome => 'गृहपृष्ठ';

  @override
  String get navExplore => 'अन्वेषण';

  @override
  String get navCreate => 'सिर्जना गर्नुहोस्';

  @override
  String get navCommunities => 'समुदायहरू';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get actionCancel => 'रद्द गर्नुहोस्';

  @override
  String get actionSave => 'सुरक्षित गर्नुहोस्';

  @override
  String get actionRetry => 'पुनः प्रयास गर्नुहोस्';

  @override
  String get actionPublish => 'प्रकाशित गर्नुहोस्';

  @override
  String get actionSignIn => 'साइन इन गर्नुहोस्';

  @override
  String get actionSignOut => 'साइन आउट गर्नुहोस्';

  @override
  String get actionSend => 'पठाउनुहोस्';

  @override
  String get actionShowMore => 'थप देखाउनुहोस्';

  @override
  String get actionUnlock => 'अनलक गर्नुहोस्';

  @override
  String get feedTitleToday => 'आजका लागि';

  @override
  String get feedSeeAll => 'सबै हेर्नुहोस्';

  @override
  String get feedCaughtUpTitle => 'तपाईं आजका लागि अद्यावधिक हुनुहुन्छ';

  @override
  String get feedCaughtUpBody =>
      'प्यागोले जानाजान थोरै-थोरै देखाउँछ। भोलि थप सामग्री यहाँ आउनेछ।';

  @override
  String get feedCaughtUpLoadAnyway => 'जे भए पनि थोरै थप देखाउनुहोस्';

  @override
  String get feedEmptyTitle => 'अहिलेसम्म केही क्युरेट गरिएको छैन';

  @override
  String get feedEmptyBody =>
      'केही लेखक वा समुदायहरूलाई फलो गर्नुहोस्, यो ठाउँ भरिन थाल्नेछ।';

  @override
  String get offlineBanner =>
      'तपाईं अफलाइन हुनुहुन्छ — सुरक्षित सामग्री देखाइँदैछ।';

  @override
  String get willPublishWhenOnline => 'फेरि अनलाइन हुँदा प्रकाशित हुनेछ';

  @override
  String get commentsEmptyTitle => 'अहिलेसम्म कुनै विचार छैन';

  @override
  String get commentsEmptyBody =>
      'यो लेखाइले तपाईंलाई के महसुस गरायो, सबैभन्दा पहिले साझा गर्नुहोस्।';

  @override
  String get commentsHint => 'आफ्नो विचार साझा गर्नुहोस्…';

  @override
  String get chatEmptyTitle => 'अहिलेसम्म कुनै कुराकानी छैन';

  @override
  String get chatEmptyBody => 'कसैको प्रोफाइलबाट कुराकानी सुरु गर्नुहोस्।';

  @override
  String get chatMessageHint => 'सन्देश…';

  @override
  String chatIsTyping(Object name) {
    return '$name टाइप गर्दैछन्…';
  }

  @override
  String get settingsTitle => 'सेटिङहरू';

  @override
  String get settingsAppearance => 'देखावट';

  @override
  String get settingsTheme => 'थिम';

  @override
  String get settingsHighContrast => 'उच्च कन्ट्रास्ट';

  @override
  String get settingsTextSize => 'अक्षर साइज';

  @override
  String get settingsLanguage => 'एपको भाषा';

  @override
  String get settingsAppLock => 'एप लक';

  @override
  String get settingsAppLockSubtitleOn =>
      'प्यागो खोल्न बायोमेट्रिक्स वा डिभाइस PIN आवश्यक पर्छ';

  @override
  String get settingsAppLockSubtitleUnsupported => 'यो डिभाइसमा उपलब्ध छैन';

  @override
  String get appLockScreenTitle => 'प्यागो लक गरिएको छ';

  @override
  String get appLockScreenBody =>
      'जारी राख्न बायोमेट्रिक्स वा तपाईंको डिभाइस PIN प्रयोग गरेर अनलक गर्नुहोस्।';

  @override
  String get errorGeneric => 'अनपेक्षित समस्या भयो।';

  @override
  String get errorOffline =>
      'तपाईं अफलाइन हुनुहुन्छ। सुरक्षित सामग्री देखाइँदैछ।';

  @override
  String get errorTimeout => 'यसमा धेरै समय लाग्यो। फेरि प्रयास गर्नुहोस्।';

  @override
  String get errorServer =>
      'प्यागोमा अहिले समस्या भइरहेको छ। फेरि प्रयास गर्नुहोस्।';

  @override
  String get errorSessionExpired =>
      'तपाईंको सत्र समाप्त भयो। कृपया फेरि साइन इन गर्नुहोस्।';

  @override
  String get draftsEmptyTitle => 'कुनै ड्राफ्ट सुरक्षित छैन';

  @override
  String get draftsEmptyBody =>
      'तपाईंले लेख्न सुरु गरेर सुरक्षित गर्नुभएको जुनसुकै कुरा यहाँ देखिनेछ — अफलाइन हुँदा पनि।';

  @override
  String get draftsStartWriting => 'लेख्न सुरु गर्नुहोस्';

  @override
  String get bookmarksEmptyTitle => 'अहिलेसम्म कुनै बुकमार्क छैन';

  @override
  String get bookmarksEmptyBody =>
      'फेरि फर्किन चाहनुभएको जुनसुकैमा बुकमार्क आइकनमा ट्याप गर्नुहोस् — अफलाइनमा पनि उपलब्ध।';
}
