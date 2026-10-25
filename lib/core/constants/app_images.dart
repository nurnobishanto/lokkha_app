class AssetImagePaths {
  static const String base = 'assets/images/';

  /// Returns the full path of an image asset.
  static String getFullPath(String name, {String format = 'png'}) {
    return '$base$name.$format';
  }

  /// Specific image path constants (only actively used assets)
  static String get appIcon => getFullPath('app_icon');
  static String get appIconHorizontal => getFullPath('app_icon_horizontal');
  static String get logo => getFullPath('logo');
  static String get splashBg => getFullPath('splash_background');
}

class AssetVectorPaths {
  static const String base = 'assets/vectors/';

  /// Returns the full path of a vector asset.
  static String getFullPath(String name) => '$base$name.svg';

  /// Specific vector path constants (only actively used assets)
  static String get onboarding1 => getFullPath('onboarding_1');
  static String get onboarding2 => getFullPath('onboarding_2');
  static String get onboarding3 => getFullPath('onboarding_3');
  static String get phoneCall => getFullPath('phone_call');
  static String get google => getFullPath('google_logo');
  static String get icVocabulary => getFullPath('ic_vocabulary');
  static String get icGk => getFullPath('ic_gk');
  static String get icVideoClass => getFullPath('ic_video_class');
  static String get icQuestionBank => getFullPath('ic_question_bank');
  static String get icQuickPractice => getFullPath('ic_quick_practice');
  static String get icCareerUpdates => getFullPath('ic_career_updates');
}

class OnlineImagePaths {
  static const String _base = 'https://lokkha.com/uploads/files/shares/app/';

  /// Returns the full path of an image asset.
  static String getFullPath(String name, {String format = 'png'}) {
    return '$_base$name.$format';
  }

  static String get whatsApp => getFullPath('whatsapp');
  static String get facebook => getFullPath('facebook');
  static String get techyfo => getFullPath('company_logo');
  static String get phoneCall => getFullPath('phone_call');
}
