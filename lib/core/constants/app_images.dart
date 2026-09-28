class AssetImagePaths {
  static const String base = 'assets/images/';

  /// Returns the full path of an image asset.
  static String getFullPath(String name, {String format = 'png'}) {
    return '$base$name.$format';
  }

  /// Specific image path constants
  static String get appIcon => getFullPath('app_icon');
  static String get appIconHorizontal => getFullPath('app_icon_horizontal');
  static String get otpImg => getFullPath('otp');
  static String get seamlessImg => getFullPath('seamless_pattern');
  static String get appleImg => getFullPath('apple', format: 'jpeg');
  static String get badgeImg => getFullPath('badge');
  static String get sliderImg => getFullPath('coming_soon_slider');
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
