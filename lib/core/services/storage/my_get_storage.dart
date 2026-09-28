import 'package:get_storage/get_storage.dart';

class MyGetStorage {
  static final GetStorage getStorage = GetStorage();

  // Cache key
  static const String randomQuestionKey = 'randomQuestionKey';
  static const String favQuestionsKey = 'favQuestionsKey';
  static const String jobKey = 'jobKey';
  static const String internationalAffairs = 'internationalAffairs';
  static const String bdAffairs = 'bdAffairs';
  static const String meUser = 'meUser';

  // Remove cache
  static Future<void> removeCache(String key) async {
    await getStorage.remove(key);
  }

  // Write Data
  static Future<void> writeCacheData(String key, dynamic value) async {
    await getStorage.write(key, value);
  }

  // READ DATA
  static dynamic readCache(String key) {
    return getStorage.read(key);
  }
}
