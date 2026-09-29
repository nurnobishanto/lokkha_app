class Strings {
  static const String hello = 'hello';
  static const String loading = 'loading';

  static const String changeTheme = 'change_theme';
  static const String changeLanguage = 'change_language';

  //
  // static const String noInternetConnection = 'no internet connection';
  // static const String serverNotResponding = 'server not responding';
  // static const String someThingWentWrong = 'something went wrong';
  // static const String apiNotFound = 'api not found';
  // static const String serverError = 'Server error';
  //static const String urlNotFound = 'Url not found';
  static String get noInternetConnection =>
      "No internet connection. Please try again later.";
  static String get serverNotResponding =>
      "Server not responding. Please try again later.";
  static String get urlNotFound => "Requested URL not found.";
  static String get serverError => "Server error. Please try again later.";
  static String get somethingWentWrong =>
      "Something went wrong. Please try again.";
}
