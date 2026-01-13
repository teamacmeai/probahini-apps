import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> get _localizedStrings {
    if (locale.languageCode == 'bn') {
      return {
        'app_title': 'প্রবাহিনী',
        'welcome': 'স্বাগতম',
        'welcome_message': 'আপনার মাসিক স্বাস্থ্যের সাথী',
        'start_chat': 'চ্যাট শুরু করুন',
        'settings': 'সেটিংস',
        'dark_mode': 'ডার্ক মোড',
        'language': 'ভাষা',
        'chat_title': 'স্বাস্থ্য সহায়ক',
        'type_message': 'আপনার প্রশ্ন লিখুন...',
        'send': 'পাঠান',
        'hello':
            'হ্যালো! আমি আপনার মাসিক স্বাস্থ্য সহায়ক। আমি আপনাকে পিরিয়ড, PMS, এবং প্রজনন স্বাস্থ্য সম্পর্কে সাহায্য করতে পারি।',
        'todays_health_tip': "আজকের টিপস",
        'emergency_help': 'জরুরী সাহায্য',
        'autonomous_coach': 'স্বায়ত্তশাসিত কোচ',
        'insights': 'অনুপ্রেরণা',
        'profile': 'প্রোফাইল',
        'analytics': 'বিশ্লেষণ',
        'generate_insights': 'অনুপ্রেরণা তৈরি করুন',
        'no_insights_yet': 'এখনো কোনো অনুপ্রেরণা নেই',
        'enable_autonomous_mode': 'স্বায়ত্তশাসিত মোড সক্রিয় করুন',
        'no_analytics_yet': 'এখনো কোনো বিশ্লেষণ নেই',
        'use_app_more': 'আরো বেশি অ্যাপ ব্যবহার করুন',
        'retry': 'পুনরায় চেষ্টা করুন',
      };
    } else {
      return {
        'app_title': 'Probahini',
        'welcome': 'Welcome',
        'welcome_message': 'Your Menstrual Health Companion',
        'start_chat': 'Start Chat',
        'settings': 'Settings',
        'dark_mode': 'Dark Mode',
        'language': 'Language',
        'chat_title': 'Health Assistant',
        'type_message': 'Type your message...',
        'send': 'Send',
        'hello':
            'Hello! I\'m your menstrual health assistant. I can help you with questions about periods, PMS, and reproductive health.',
        'todays_health_tip': "Today's Health Tip",
        'emergency_help': 'Emergency Help',
        'autonomous_coach': 'Autonomous Coach',
        'insights': 'Insights',
        'profile': 'Profile',
        'analytics': 'Analytics',
        'generate_insights': 'Generate Insights',
        'no_insights_yet': 'No insights yet',
        'enable_autonomous_mode': 'Enable autonomous mode to get personalized insights',
        'no_analytics_yet': 'No analytics yet',
        'use_app_more': 'Use the app more to see your coaching analytics',
        'retry': 'Retry',
      };
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'bn'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
