class AssetImagePaths {
  static const String base = 'assets/images/';

  /// Returns the full path of an image asset.
  static String getFullPath(String name, {String format = 'png'}) {
    return '$base$name.$format';
  }

  /// Specific image path constants
  static String get appIcon => getFullPath('app_icon');
  static String get appIconHorizontal => getFullPath('app_icon_horizontal');
  static String get logo => getFullPath('logo');
  static String get otpImg => getFullPath('otp');
  static String get seamlessImg => getFullPath('seamless_pattern');
  static String get splashBg => getFullPath('splash_background');
  static String get splashIcon => getFullPath('splash_icon');
}

class AssetVectorPaths {
  static const String base = 'assets/vectors/';

  /// Returns the full path of a vector asset.
  static String getFullPath(String name) => '$base$name.svg';

  /// Specific vector path constants
  static String get onboarding1 => getFullPath('onboarding_1');
  static String get onboarding2 => getFullPath('onboarding_2');
  static String get onboarding3 => getFullPath('onboarding_3');
  static String get splashIcon => getFullPath('splash_icon');
  static String get logo => getFullPath('logo');
  static String get phoneCall => getFullPath('phone_call');
  static String get google => getFullPath('google_logo');
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
