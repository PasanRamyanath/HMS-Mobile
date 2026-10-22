/// Sri Lankan Trilingual Localization Engine (English, Sinhala, Tamil)
enum AppLanguage {
  en,
  si,
  ta,
}

class AppTranslations {
  static AppLanguage currentLanguage = AppLanguage.en;

  static const Map<String, Map<AppLanguage, String>> _strings = {
    // App Header & Common
    'app_title': {
      AppLanguage.en: 'Ceylon Heritage HMS Cloud',
      AppLanguage.si: 'සිලෝන් හෙරිටේජ් හෝටල් කළමනාකරණ පද්ධතිය',
      AppLanguage.ta: 'சிலோன் ஹெரிட்டேஜ் ஹோட்டல் முகாமைத்துவ முறைமை',
    },
    'cbsl_mid_rate': {
      AppLanguage.en: 'CBSL Mid-Rate',
      AppLanguage.si: 'ශ්‍රී ලංකා මහ බැංකු මැදි අනුපාතය',
      AppLanguage.ta: 'இலங்கை மத்திய வங்கி மத்திய விகிதம்',
    },
    'cloud_synced': {
      AppLanguage.en: 'Cloud Synced (Mumbai ap-south-1)',
      AppLanguage.si: 'ක්ලවුඩ් සම්බන්ධිතයි (මුම්බායි)',
      AppLanguage.ta: 'கிளவுட் இணைக்கப்பட்டது (மும்பை)',
    },
    'offline_mode': {
      AppLanguage.en: 'Offline Cache Active',
      AppLanguage.si: 'නොබැඳි දත්ත ගබඩාව ක්‍රියාත්මකයි',
      AppLanguage.ta: 'ஆஃப்லைன் சேமிப்பு செயலில் உள்ளது',
    },

    // Navigation / Modules
    'touchpoints': {
      AppLanguage.en: 'Touchpoints Hub',
      AppLanguage.si: 'සේවා මධ්‍යස්ථානය',
      AppLanguage.ta: 'சேவை மையம்',
    },
    'dashboard': {
      AppLanguage.en: 'Executive Command',
      AppLanguage.si: 'විධායක පාලක පුවරුව',
      AppLanguage.ta: 'நிறைவேற்று கட்டுப்பாட்டு பலகை',
    },
    'tape_chart': {
      AppLanguage.en: '14-Day Tape Chart',
      AppLanguage.si: 'දින 14 කාමර සටහන',
      AppLanguage.ta: '14-நாள் அறை அட்டவணை',
    },
    'express_checkin': {
      AppLanguage.en: 'Express Check-In',
      AppLanguage.si: 'ක්ෂණික ඇතුළත් වීම',
      AppLanguage.ta: 'விரைவு பதிவு',
    },
    'waiter_pos': {
      AppLanguage.en: 'Waiter POS',
      AppLanguage.si: 'වේටර් ඇණවුම් පද්ධතිය',
      AppLanguage.ta: 'பரிசாரகர் விற்பனை புள்ளி',
    },
    'dark_kds': {
      AppLanguage.en: 'Dark OLED KDS',
      AppLanguage.si: 'මුළුතැන්ගෙයි පුවරුව (KDS)',
      AppLanguage.ta: 'சமையலறை காட்சி திரை',
    },
    'bar_bot': {
      AppLanguage.en: 'Sunset Bar BOT',
      AppLanguage.si: 'බාර් ඇණවුම් පුවරුව (BOT)',
      AppLanguage.ta: 'பார் கட்டளை திரை',
    },
    'housekeeping': {
      AppLanguage.en: 'Housekeeping Runner',
      AppLanguage.si: 'කාමර පිරිසිදු කිරීම්',
      AppLanguage.ta: 'அறை பராமரிப்பு',
    },
    'split_folios': {
      AppLanguage.en: 'Split Folios & LankaQR',
      AppLanguage.si: 'බිල්පත් බෙදීම සහ ලංකාQR',
      AppLanguage.ta: 'பில் பிரிப்பு மற்றும் லங்காQR',
    },
    'guest_dining': {
      AppLanguage.en: 'Contactless Guest Dining',
      AppLanguage.si: 'ස්පර්ශ රහිත අමුත්තන්ගේ ඇණවුම්',
      AppLanguage.ta: 'தொடர்பற்ற விருந்தினர் உணவு',
    },
    'direct_booking': {
      AppLanguage.en: 'Direct Booking Engine',
      AppLanguage.si: 'සෘජු කාමර වෙන්කිරීම්',
      AppLanguage.ta: 'நேரடி அறை முன்பதிவு',
    },
    'weddings_poruwa': {
      AppLanguage.en: 'Banquets & Poruwa',
      AppLanguage.si: 'උත්සව ශාලා සහ පෝරු මඟුල්',
      AppLanguage.ta: 'மண்டபங்கள் மற்றும் திருமண நிகழ்வுகள்',
    },
    'ayurveda_spa': {
      AppLanguage.en: 'Ayurveda & Wellness Spa',
      AppLanguage.si: 'ආයුර්වේද සුවතා මධ්‍යස්ථානය',
      AppLanguage.ta: 'ஆயுர்வேத ஆரோக்கிய ஸ்பா',
    },
    'inventory_bom': {
      AppLanguage.en: 'FIFO Stores & Recipe BOM',
      AppLanguage.si: 'ගබඩා කළමනාකරණය සහ වට්ටෝරු',
      AppLanguage.ta: 'சரக்கு இருப்பு மற்றும் சமையல் குறிப்பு',
    },
    'sltda_taxes': {
      AppLanguage.en: 'SLTDA & IRD Statutory Tax',
      AppLanguage.si: 'සංචාරක මණ්ඩල සහ IRD බදු ගණනය',
      AppLanguage.ta: 'சுற்றுலா அபிவிருத்தி & வரி கணிப்பு',
    },
    'hospitality_payroll': {
      AppLanguage.en: '10% SC & EPF/ETF Payroll',
      AppLanguage.si: '10% සේවා ගාස්තු සහ EPF/ETF වැටුප්',
      AppLanguage.ta: '10% சேவை கட்டணம் & EPF/ETF சம்பளம்',
    },
    'settings': {
      AppLanguage.en: 'System Settings',
      AppLanguage.si: 'පද්ධති සැකසුම්',
      AppLanguage.ta: 'அமைப்பு அமைப்புகள்',
    },

    // KPI & Headcount Metrics
    'occupancy_rate': {
      AppLanguage.en: 'Occupancy Rate',
      AppLanguage.si: 'කාමර පිරීමේ ප්‍රතිශතය',
      AppLanguage.ta: 'அறை நிரம்பல் வீதம்',
    },
    'adr_metric': {
      AppLanguage.en: 'Average Daily Rate (ADR)',
      AppLanguage.si: 'සාමාන්‍ය දෛනික අනුපාතය',
      AppLanguage.ta: 'சராசரி தினசரி வீதம்',
    },
    'revpar_metric': {
      AppLanguage.en: 'RevPAR',
      AppLanguage.si: 'ලබාගත හැකි කාමරයක ආදායම',
      AppLanguage.ta: 'கிடைக்கக்கூடிய அறை வருவாய்',
    },
    'headcount_breakfast': {
      AppLanguage.en: 'Breakfast Headcount',
      AppLanguage.si: 'උදෑසන ආහාර ගණනය',
      AppLanguage.ta: 'காலை உணவு எண்ணிக்கை',
    },
    'headcount_lunch': {
      AppLanguage.en: 'Lunch Headcount',
      AppLanguage.si: 'දිවා ආහාර ගණනය',
      AppLanguage.ta: 'மதிய உணவு எண்ணிக்கை',
    },
    'headcount_dinner': {
      AppLanguage.en: 'Dinner Headcount',
      AppLanguage.si: 'රාත්‍රී ආහාර ගණනය',
      AppLanguage.ta: 'இரவு உணவு எண்ணிக்கை',
    },

    // Meal Plans
    'plan_ro': {
      AppLanguage.en: 'Room Only (RO)',
      AppLanguage.si: 'කාමරය පමණි',
      AppLanguage.ta: 'அறை மட்டும்',
    },
    'plan_bb': {
      AppLanguage.en: 'Bed & Breakfast (BB)',
      AppLanguage.si: 'නවාතැන සහ උදෑසන ආහාරය',
      AppLanguage.ta: 'படுக்கை & காலை உணவு',
    },
    'plan_hb': {
      AppLanguage.en: 'Half Board (HB)',
      AppLanguage.si: 'අර්ධ නේවාසික (HB)',
      AppLanguage.ta: 'அரை போர்டு (HB)',
    },
    'plan_fb': {
      AppLanguage.en: 'Full Board (FB)',
      AppLanguage.si: 'පූර්ණ නේවාසික (FB)',
      AppLanguage.ta: 'முழு போர்டு (FB)',
    },
    'plan_ai': {
      AppLanguage.en: 'All Inclusive (AI)',
      AppLanguage.si: 'සියල්ල ඇතුළත් (AI)',
      AppLanguage.ta: 'அனைத்தும் உள்ளடக்கியது',
    },

    // Room Status
    'status_clean': {
      AppLanguage.en: 'Clean & Inspected',
      AppLanguage.si: 'පිරිසිදු කර පරීක්ෂා කළ',
      AppLanguage.ta: 'சுத்தப்படுத்தப்பட்டு பரிசோதிக்கப்பட்டது',
    },
    'status_dirty': {
      AppLanguage.en: 'Dirty / Turnover',
      AppLanguage.si: 'පිරිසිදු කළ යුතුයි',
      AppLanguage.ta: 'சுத்தப்படுத்த வேண்டும்',
    },
    'status_occupied': {
      AppLanguage.en: 'Occupied',
      AppLanguage.si: 'නේවාසිකයි',
      AppLanguage.ta: 'குடியிருப்பு',
    },
    'status_maintenance': {
      AppLanguage.en: 'Maintenance',
      AppLanguage.si: 'නඩත්තු කරමින්',
      AppLanguage.ta: 'பராமரிப்பில்',
    },

    // Spice Levels
    'spice_mild': {
      AppLanguage.en: 'Mild Spice',
      AppLanguage.si: 'මිරිස් අඩු',
      AppLanguage.ta: 'குறைந்த காரம்',
    },
    'spice_medium': {
      AppLanguage.en: 'Medium Spice',
      AppLanguage.si: 'මධ්‍යම සැර',
      AppLanguage.ta: 'நடுத்தர காரம்',
    },
    'spice_hot': {
      AppLanguage.en: 'Sri Lankan Spicy',
      AppLanguage.si: 'ලංකාවේ සැරට',
      AppLanguage.ta: 'இலங்கை காரம்',
    },
    'spice_extra': {
      AppLanguage.en: 'Fiery Kochchi Chilli',
      AppLanguage.si: 'කොච්චි මිරිස් සැරට',
      AppLanguage.ta: 'கொச்சி மிளகாய் அதி காரம்',
    },

    // Actions & Buttons
    'fire_kot': {
      AppLanguage.en: 'Fire KOT to Kitchen',
      AppLanguage.si: 'මුළුතැන්ගෙට ඇණවුම යවන්න',
      AppLanguage.ta: 'சமையலறைக்கு அனுப்புக',
    },
    'mark_ready': {
      AppLanguage.en: 'Mark as Ready',
      AppLanguage.si: 'සූදානම් බව සලකුණු කරන්න',
      AppLanguage.ta: 'தயார் என குறிக்கவும்',
    },
    'mark_served': {
      AppLanguage.en: 'Mark as Served',
      AppLanguage.si: 'පිළිගැන්වූ බව සලකුණු කරන්න',
      AppLanguage.ta: 'வழங்கப்பட்டது என குறிக்கவும்',
    },
    'generate_lankaqr': {
      AppLanguage.en: 'Generate Dynamic LankaQR',
      AppLanguage.si: 'ලංකාQR කේතය සාදන්න',
      AppLanguage.ta: 'டைனமிக் லங்காQR உருவாக்கு',
    },
    'confirm_payment': {
      AppLanguage.en: 'Confirm Payment',
      AppLanguage.si: 'ගෙවීම තහවුරු කරන්න',
      AppLanguage.ta: 'பணம் செலுத்தலை உறுதிப்படுத்துக',
    },
    'check_in_guest': {
      AppLanguage.en: 'Check-In Guest',
      AppLanguage.si: 'අමුත්තා ඇතුළත් කරගන්න',
      AppLanguage.ta: 'விருந்தினரை பதிவு செய்க',
    },
    'quick_login_pin': {
      AppLanguage.en: 'Staff 4-Digit Quick PIN',
      AppLanguage.si: 'කාර්ය මණ්ඩල ඉක්මන් PIN අංකය',
      AppLanguage.ta: 'பணியாளர் 4-இலக்க விரைவு பின்',
    },
    'switch_role': {
      AppLanguage.en: 'Switch Role / Profile',
      AppLanguage.si: 'තනතුර මාරු කරන්න',
      AppLanguage.ta: 'பதவியை மாற்றுக',
    },
  };

  /// Translate key to the active language
  static String tr(String key) {
    final entry = _strings[key];
    if (entry == null) return key;
    return entry[currentLanguage] ?? entry[AppLanguage.en] ?? key;
  }

  /// Change active language
  static void setLanguage(AppLanguage language) {
    currentLanguage = language;
  }

  /// Short display label for language toggle (e.g. "EN", "සිං", "தமி")
  static String get languageLabel {
    switch (currentLanguage) {
      case AppLanguage.en:
        return 'EN';
      case AppLanguage.si:
        return 'සිං';
      case AppLanguage.ta:
        return 'தமி';
    }
  }
}
