import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/locale_provider.dart';

/// Centralized bilingual dictionary for Legal Helper app (English & Hindi)
class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    // ----------------- Navigation & App Bar -----------------
    'nav_home': {
      'en': 'Home',
      'hi': 'होम',
    },
    'nav_explore': {
      'en': 'Explore',
      'hi': 'एक्सप्लोर',
    },
    'nav_saved': {
      'en': 'Saved',
      'hi': 'सहेजे गए',
    },
    'nav_me': {
      'en': 'Me',
      'hi': 'प्रोफाइल',
    },
    'ai_advisor_fab': {
      'en': '+ AI Advisor',
      'hi': '+ कानूनी सलाहकार',
    },

    // ----------------- Home Screen -----------------
    'workspace_title': {
      'en': 'Legal AI Workspace',
      'hi': 'कानूनी एआई वर्कस्पेस',
    },
    'workspace_subtitle': {
      'en': 'Instant statutory guidance, drafting & analysis',
      'hi': 'त्वरित वैधानिक मार्गदर्शन, प्रारूपण एवं विश्लेषण',
    },
    'search_placeholder': {
      'en': 'Ask Legal AI (e.g. notice response, contract terms)...',
      'hi': 'कानूनी एआई से पूछें (उदा. नोटिस उत्तर, अनुबंध शर्तें)...',
    },
    'scam_shield_title': {
      'en': 'Emergency Scam Shield',
      'hi': 'आपातकालीन धोखाधड़ी शील्ड',
    },
    'scam_shield_desc': {
      'en':
          'Verify suspicious SMS, calls & payment threats with instant cyber crime helpline link.',
      'hi':
          'संदिग्ध एसएमएस, कॉल और धोखाधड़ी संदेशों की तुरंत जांच करें व साइबर हेल्पलाइन से जुड़ें।',
    },
    'run_scam_scan': {
      'en': 'Run Scam Scan',
      'hi': 'धोखाधड़ी जांचें',
    },
    'quick_tools_title': {
      'en': 'Quick-Access Tools',
      'hi': 'त्वरित-पहुंच उपकरण',
    },
    'tool_simplifier': {
      'en': 'Simplifier',
      'hi': 'सरलीकरण',
    },
    'tool_simplifier_desc': {
      'en': 'Plain English',
      'hi': 'सरल भाषा',
    },
    'tool_drafting': {
      'en': 'Drafting',
      'hi': 'प्रारूपण',
    },
    'tool_drafting_desc': {
      'en': 'Agreements',
      'hi': 'अनुबंध व पत्र',
    },
    'tool_notice_reply': {
      'en': 'Notice Reply',
      'hi': 'नोटिस उत्तर',
    },
    'tool_notice_reply_desc': {
      'en': 'Defense Strategy',
      'hi': 'बचाव रणनीति',
    },
    'tool_legal_aid': {
      'en': 'Legal Aid',
      'hi': 'कानूनी सहायता',
    },
    'tool_legal_aid_desc': {
      'en': 'Article 39A Free Aid',
      'hi': 'अनुच्छेद 39A सहायता',
    },
    'saved_title': {
      'en': 'Saved Analysis & Drafts',
      'hi': 'सहेजे गए विश्लेषण और प्रारूप',
    },
    'view_all': {
      'en': 'View All',
      'hi': 'सभी देखें',
    },
    'no_saved': {
      'en': 'No saved documents yet',
      'hi': 'अभी कोई सहेजे गए दस्तावेज़ नहीं हैं',
    },
    'start_saving': {
      'en': 'Generate a draft or analyze a notice to save here',
      'hi': 'प्रारूप बनाएं या नोटिस विश्लेषण करके यहां सहेजें',
    },
    'disclaimer_short': {
      'en': 'Legal Information Disclaimer: Not a substitute for professional legal counsel.',
      'hi': 'कानूनी सूचना अस्वीकरण: यह पेशेवर कानूनी वकील का विकल्प नहीं है।',
    },

    // ----------------- Explore Screen -----------------
    'explore_title': {
      'en': 'Explore Legal Tools',
      'hi': 'कानूनी उपकरण एक्सप्लोर करें',
    },
    'explore_search': {
      'en': 'Search legal tools & features...',
      'hi': 'कानूनी उपकरण एवं सुविधाएं खोजें...',
    },
    'cat_ai_assistance': {
      'en': 'AI ASSISTANCE',
      'hi': 'एआई कानूनी सहायता',
    },
    'cat_documents': {
      'en': 'DOCUMENTS',
      'hi': 'दस्तावेज़ एवं अनुपालन',
    },
    'cat_safety': {
      'en': 'SAFETY & HELP',
      'hi': 'सुरक्षा एवं सहायता',
    },
    'tool_legal_advisor': {
      'en': 'AI Legal Advisor',
      'hi': 'एआई कानूनी सलाहकार',
    },
    'tool_legal_advisor_desc': {
      'en': 'Conversational statutory guidance with citations',
      'hi': 'कानूनी धाराओं और उदाहरणों के साथ त्वरित परामर्श',
    },
    'tool_research': {
      'en': 'Legal Research & Precedents',
      'hi': 'कानूनी शोध और निर्णय',
    },
    'tool_research_desc': {
      'en': 'Search case law, statutory citations and ratios',
      'hi': 'भारतीय अदालती निर्णय, धाराएं और कानूनी नज़ीरें खोजें',
    },
    'tool_simplifier_full': {
      'en': 'Legal Document Simplifier',
      'hi': 'कानूनी दस्तावेज़ सरलीकरण',
    },
    'tool_simplifier_full_desc': {
      'en': 'Translate contracts into plain language',
      'hi': 'जटिल कानूनी अनुबंधों को सरल भाषा में समझें',
    },
    'tool_drafting_full': {
      'en': 'Statutory Drafting Assistant',
      'hi': 'वैधानिक प्रारूपण सहायक',
    },
    'tool_drafting_full_desc': {
      'en': 'Draft rental deeds, NDAs, contracts & demand notices',
      'hi': 'किरायानामा, अनुबंध, शपथ पत्र और कानूनी मांग पत्र बनाएं',
    },
    'tool_notice_reply_full': {
      'en': 'Notice Reply Helper',
      'hi': 'नोटिस प्रत्युत्तर सहायक',
    },
    'tool_notice_reply_full_desc': {
      'en': 'Analyze legal notices and prepare formal defenses',
      'hi': 'कानूनी नोटिस का विश्लेषण करें और औपचारिक जवाब तैयार करें',
    },
    'tool_vault': {
      'en': 'Encrypted Legal Vault',
      'hi': 'सुरक्षित कानूनी वॉल्ट',
    },
    'tool_vault_desc': {
      'en': 'Store contracts and deeds with client-side security',
      'hi': 'अपने सभी महत्वपूर्ण दस्तावेज़ सुरक्षित रूप से रखें',
    },
    'tool_scam_detector': {
      'en': 'Scam & Fraud Shield',
      'hi': 'धोखाधड़ी एवं स्कैम शील्ड',
    },
    'tool_scam_detector_desc': {
      'en': 'Scan suspicious messages and fake warrants',
      'hi': 'फर्जी कॉल, एसएमएस और वित्तीय धोखाधड़ी संदेशों की पहचान करें',
    },
    'tool_evidence': {
      'en': 'Evidence Timeline',
      'hi': 'साक्ष्य समयरेखा',
    },
    'tool_evidence_desc': {
      'en': 'Organize facts, dates, and exhibits chronologically',
      'hi': 'घटनाओं और साक्ष्यों को कालक्रम में व्यवस्थित करें',
    },
    'tool_lawyer_prep': {
      'en': 'Lawyer Consultation Prep',
      'hi': 'वकील परामर्श तैयारी',
    },
    'tool_lawyer_prep_desc': {
      'en': 'Generate organized case briefs and strategic questions',
      'hi': 'वकील से मिलने से पहले केस सारांश और मुख्य प्रश्न तैयार करें',
    },
    'tool_legal_aid_full': {
      'en': 'Free Legal Aid Finder',
      'hi': 'मुफ्त कानूनी सहायता खोजें',
    },
    'tool_legal_aid_full_desc': {
      'en': 'NALSA & DLSA free legal representation directory',
      'hi': 'नालसा (NALSA) और डालसा (DLSA) से सरकारी कानूनी मदद प्राप्त करें',
    },

    // ----------------- Saved Screen -----------------
    'saved_header': {
      'en': 'Saved Documents & Advice',
      'hi': 'सहेजे गए दस्तावेज़ और सलाह',
    },
    'saved_search': {
      'en': 'Search saved drafts & advice...',
      'hi': 'सहेजे गए प्रारूप एवं सलाह खोजें...',
    },
    'filter_all': {
      'en': 'All',
      'hi': 'सभी',
    },
    'filter_advice': {
      'en': 'Advice',
      'hi': 'सलाह',
    },
    'filter_draft': {
      'en': 'Drafts',
      'hi': 'प्रारूप',
    },
    'filter_notice': {
      'en': 'Notices',
      'hi': 'नोटिस',
    },
    'filter_document': {
      'en': 'Documents',
      'hi': 'दस्तावेज़',
    },
    'empty_saved_title': {
      'en': 'Your library is empty',
      'hi': 'आपकी लाइब्रेरी खाली है',
    },
    'empty_saved_desc': {
      'en':
          'Generated legal drafts, advice, and simplified documents will appear here.',
      'hi':
          'तैयार किए गए कानूनी प्रारूप, सलाह और दस्तावेज़ यहां दिखाई देंगे।',
    },

    // ----------------- Profile Screen -----------------
    'account_hub': {
      'en': 'ACCOUNT HUB',
      'hi': 'अकाउंट हब',
    },
    'profile_settings': {
      'en': 'Profile & Settings',
      'hi': 'प्रोफाइल एवं सेटिंग्स',
    },
    'verified_member': {
      'en': 'Verified Member',
      'hi': 'सत्यापित सदस्य',
    },
    'saved_docs_count': {
      'en': 'Saved Documents',
      'hi': 'सहेजे गए दस्तावेज़',
    },
    'cloud_sync': {
      'en': 'Cloud Sync Status',
      'hi': 'क्लाउड सिंक स्थिति',
    },
    'cloud_active': {
      'en': 'Active',
      'hi': 'सक्रिय',
    },
    'appearance_localization': {
      'en': 'APPEARANCE & LOCALIZATION',
      'hi': 'दिखावट एवं भाषा',
    },
    'app_theme_mode': {
      'en': 'App Theme Mode',
      'hi': 'ऐप थीम मोड',
    },
    'theme_midnight': {
      'en': 'Midnight',
      'hi': 'मिडनाइट',
    },
    'theme_light': {
      'en': 'Light',
      'hi': 'लाइट',
    },
    'theme_system': {
      'en': 'System',
      'hi': 'सिस्टम',
    },
    'interface_language': {
      'en': 'Interface Language',
      'hi': 'इंटरफ़ेस भाषा',
    },
    'current_lang_en': {
      'en': 'Current: English (India)',
      'hi': 'वर्तमान: अंग्रेज़ी (भारत)',
    },
    'current_lang_hi': {
      'en': 'Current: हिन्दी (India)',
      'hi': 'वर्तमान: हिन्दी (भारत)',
    },
    'alerts_reminders': {
      'en': 'ALERTS & REMINDERS',
      'hi': 'अलर्ट एवं अनुस्मारक',
    },
    'legal_deadlines': {
      'en': 'Legal Deadlines & Reminders',
      'hi': 'कानूनी समयसीमा एवं अनुस्मारक',
    },
    'legal_deadlines_desc': {
      'en':
          'Get timely notifications before legal notice periods and case hearing dates expire.',
      'hi':
          'नोटिस की अंतिम तिथि और सुनवाई से पहले समय पर सूचनाएं पाएं।',
    },
    'help_trust': {
      'en': 'HELP & TRUST',
      'hi': 'सहायता एवं सुरक्षा',
    },
    'privacy_policy': {
      'en': 'Privacy Policy & Data Security',
      'hi': 'गोपनीयता नीति एवं डेटा सुरक्षा',
    },
    'privacy_policy_sub': {
      'en': 'End-to-end client confidentiality',
      'hi': 'पूर्ण गोपनीयता एवं डेटा सुरक्षा',
    },
    'community_open_source': {
      'en': 'Community & Open Source',
      'hi': 'कम्युनिटी एवं ओपन सोर्स',
    },
    'contact_support': {
      'en': 'Contact Human Support',
      'hi': 'ग्राहक सहायता से संपर्क करें',
    },
    'support_hours': {
      'en': 'Available Mon-Sat 9AM-8PM IST',
      'hi': 'उपलब्ध: सोम-शनि सुबह 9 से रात 8 बजे',
    },
    'sign_out': {
      'en': 'Sign Out of Account',
      'hi': 'अकाउंट से लॉग आउट करें',
    },

    // ----------------- Notice Reply Screen -----------------
    'notice_reply_title': {
      'en': 'Notice Reply Helper',
      'hi': 'नोटिस प्रत्युत्तर सहायक',
    },
    'notice_reply_subtitle': {
      'en':
          'Turn confusing legal notices into a clear, calm, and statutory formal response.',
      'hi':
          'जटिल कानूनी नोटिसों को एक स्पष्ट, शांत और वैधानिक उत्तर में बदलें।',
    },
    'instant_legal_assistant': {
      'en': 'Instant Legal Assistant',
      'hi': 'त्वरित कानूनी सहायक',
    },
    'safe_confidential': {
      'en': 'Safe & Confidential',
      'hi': 'सुरक्षित एवं गोपनीय',
    },
    'safe_confidential_desc': {
      'en':
          'AI securely breaks down allegations, calculates response deadlines, and drafts your rebuttal.',
      'hi':
          'एआई सुरक्षित रूप से आरोपों का विश्लेषण करता है, अंतिम तिथि की गणना करता है और उत्तर तैयार करता है।',
    },
    'upload_heading': {
      'en': 'Snap a Photo or Upload PDF',
      'hi': 'फोटो खींचें या पीडीएफ अपलोड करें',
    },
    'upload_desc': {
      'en':
          'We will automatically read dates, sender details, and claimed amounts for you!',
      'hi':
          'हम आपके लिए तारीखें, प्रेषक का विवरण और दावा की गई राशि अपने आप पढ़ लेंगे!',
    },
    'notice_text_heading': {
      'en': 'NOTICE TEXT OR SUMMARY',
      'hi': 'नोटिस पाठ या सारांश',
    },
    'voice_dictate': {
      'en': 'Voice Dictate',
      'hi': 'बोलकर लिखें',
    },
    'notice_placeholder': {
      'en':
          'Paste the notice text or summarize what happened in simple words (e.g. loan dispute, credit card notice, tenancy issue)...',
      'hi':
          'नोटिस का पाठ चिपकाएं या सरल शब्दों में बताएं कि क्या हुआ (उदा. ऋण विवाद, क्रेडिट कार्ड नोटिस, किरायेदारी समस्या)...',
    },
    'goal_prefix': {
      'en': 'Goal:',
      'hi': 'लक्ष्य:',
    },
    'goal_limitation': {
      'en': 'Check Limitation Period',
      'hi': 'मियाद अवधि जांचें',
    },
    'goal_settlement': {
      'en': 'Request Settlement',
      'hi': 'समझौता अनुरोध',
    },
    'goal_deny': {
      'en': 'Deny Allegations',
      'hi': 'आरोपों का खंडन',
    },
    'who_sent_notice': {
      'en': 'WHO SENT THE NOTICE?',
      'hi': 'नोटिस किसने भेजा?',
    },
    'amount_claimed': {
      'en': 'AMOUNT CLAIMED',
      'hi': 'दावा की गई राशि',
    },
    'analyze_rebuttal_btn': {
      'en': 'Analyze & Draft Formal Rebuttal',
      'hi': 'विश्लेषण करें और औपचारिक उत्तर बनाएं',
    },
    'review_pdf_disclaimer': {
      'en': 'You will review, customize & export to PDF before sending.',
      'hi': 'भेजने से पहले आप समीक्षा, संपादन और पीडीएफ निर्यात कर सकते हैं।',
    },

    // ----------------- Drafting Screen -----------------
    'drafting_assistant_title': {
      'en': 'Drafting Assistant',
      'hi': 'प्रारूपण सहायक',
    },
    'ai_assistant_online': {
      'en': 'AI Assistant Online',
      'hi': 'एआई सहायक ऑनलाइन',
    },
    'details_terms_step': {
      'en': 'Step 3 of 4: Details & Terms',
      'hi': 'चरण 3 of 4: विवरण एवं शर्तें',
    },
    'min_remaining': {
      'en': '~1 min remaining',
      'hi': '~1 मिनट शेष',
    },
    'today_instant_drafting': {
      'en': 'TODAY • INSTANT LEGAL DRAFTING',
      'hi': 'आज • त्वरित कानूनी प्रारूपण',
    },
    'drafting_in_progress': {
      'en': 'Drafting in Progress...',
      'hi': 'प्रारूपण प्रगति पर है...',
    },
    'preview_btn': {
      'en': 'Preview',
      'hi': 'पूर्वावलोकन',
    },
    'quick_add_prefix': {
      'en': 'Quick add:',
      'hi': 'त्वरित जोड़ें:',
    },
  };

  /// Translate a key based on the given language code (defaults to 'en' if key missing)
  static String tr(String key, String langCode) {
    final entry = _translations[key];
    if (entry == null) return key;
    return entry[langCode] ?? entry['en'] ?? key;
  }
}

/// Convenience extension on WidgetRef to get translated string
extension WidgetRefTranslation on WidgetRef {
  String tr(String key) {
    final locale = watch(localeProvider);
    return AppTranslations.tr(key, locale.languageCode);
  }

  bool get isHindi {
    return watch(localeProvider).languageCode == 'hi';
  }
}
