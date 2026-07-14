// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'بياغو';

  @override
  String get appTagline => 'مكان هادئ لما تريد أن تقوله.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navExplore => 'استكشف';

  @override
  String get navCreate => 'إنشاء';

  @override
  String get navCommunities => 'المجتمعات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionPublish => 'نشر';

  @override
  String get actionSignIn => 'تسجيل الدخول';

  @override
  String get actionSignOut => 'تسجيل الخروج';

  @override
  String get actionSend => 'إرسال';

  @override
  String get actionShowMore => 'عرض المزيد';

  @override
  String get actionUnlock => 'فتح القفل';

  @override
  String get feedTitleToday => 'لهذا اليوم';

  @override
  String get feedSeeAll => 'عرض الكل';

  @override
  String get feedCaughtUpTitle => 'لقد اطّلعت على كل شيء لهذا اليوم';

  @override
  String get feedCaughtUpBody =>
      'يعرض بياغو القليل في كل مرة عن قصد. سيتوفر المزيد غدًا.';

  @override
  String get feedCaughtUpLoadAnyway => 'عرض المزيد على أي حال';

  @override
  String get feedEmptyTitle => 'لا يوجد محتوى مُختار بعد';

  @override
  String get feedEmptyBody =>
      'تابع بعض الكتّاب أو المجتمعات وستبدأ هذه المساحة بالامتلاء.';

  @override
  String get offlineBanner =>
      'أنت غير متصل بالإنترنت — يتم عرض المحتوى المحفوظ.';

  @override
  String get willPublishWhenOnline => 'سيُنشر عند عودة الاتصال بالإنترنت';

  @override
  String get commentsEmptyTitle => 'لا توجد آراء بعد';

  @override
  String get commentsEmptyBody => 'كن أول من يشارك ما أثاره هذا النص لديك.';

  @override
  String get commentsHint => 'شارك فكرة…';

  @override
  String get chatEmptyTitle => 'لا توجد محادثات بعد';

  @override
  String get chatEmptyBody => 'ابدأ محادثة من الملف الشخصي لأحدهم.';

  @override
  String get chatMessageHint => 'رسالة…';

  @override
  String chatIsTyping(Object name) {
    return '‏$name يكتب الآن…';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsTheme => 'السمة';

  @override
  String get settingsHighContrast => 'تباين عالٍ';

  @override
  String get settingsTextSize => 'حجم النص';

  @override
  String get settingsLanguage => 'لغة التطبيق';

  @override
  String get settingsAppLock => 'قفل التطبيق';

  @override
  String get settingsAppLockSubtitleOn =>
      'يتطلب فتح بياغو بصمة أو رقم PIN الخاص بالجهاز';

  @override
  String get settingsAppLockSubtitleUnsupported => 'غير متاح على هذا الجهاز';

  @override
  String get appLockScreenTitle => 'بياغو مقفل';

  @override
  String get appLockScreenBody =>
      'افتح القفل باستخدام البصمة أو رقم PIN الخاص بجهازك للمتابعة.';

  @override
  String get errorGeneric => 'حدث خطأ غير متوقع.';

  @override
  String get errorOffline => 'أنت غير متصل بالإنترنت. يتم عرض المحتوى المحفوظ.';

  @override
  String get errorTimeout => 'استغرق هذا وقتًا طويلاً. يرجى المحاولة مرة أخرى.';

  @override
  String get errorServer => 'يواجه بياغو مشكلة الآن. يرجى المحاولة مرة أخرى.';

  @override
  String get errorSessionExpired =>
      'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get draftsEmptyTitle => 'لا توجد مسودات محفوظة';

  @override
  String get draftsEmptyBody =>
      'كل ما تبدأ في كتابته وحفظه سيظهر هنا — حتى دون اتصال بالإنترنت.';

  @override
  String get draftsStartWriting => 'ابدأ الكتابة';

  @override
  String get bookmarksEmptyTitle => 'لا توجد إشارات مرجعية بعد';

  @override
  String get bookmarksEmptyBody =>
      'اضغط على أيقونة الإشارة المرجعية على أي شيء تريد العودة إليه — متاح أيضًا دون اتصال.';
}
