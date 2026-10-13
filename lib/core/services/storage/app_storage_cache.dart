import 'dart:convert';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';

class _StorageWrapper {
  const _StorageWrapper();

  bool hasData(String key) => AppStorageCache.hasData(key);
  dynamic read(String key) => AppStorageCache.readCache(key);
  Future<void> write(String key, dynamic val) => AppStorageCache.writeCacheData(key, val);
  Future<void> remove(String key) => AppStorageCache.removeCache(key);
}

class AppStorageCache {
  static const _StorageWrapper getStorage = _StorageWrapper();
  static final Map<String, dynamic> _memoryCache = {};

  // Cache keys
  static const String randomQuestionKey = 'randomQuestionKey';
  static const String favQuestionsKey = 'favQuestionsKey';
  static const String jobKey = 'jobKey';
  static const String internationalAffairs = 'internationalAffairs';
  static const String bdAffairs = 'bdAffairs';
  static const String meUser = 'meUser';

  static bool hasData(String key) {
    if (_memoryCache.containsKey(key)) return true;
    try {
      return MySharedPref.prefs.containsKey(key);
    } catch (_) {
      return false;
    }
  }

  // Remove cache
  static Future<void> removeCache(String key) async {
    _memoryCache.remove(key);
    try {
      await MySharedPref.prefs.remove(key);
    } catch (_) {}
  }

  // Write Data
  static Future<void> writeCacheData(String key, dynamic value) async {
    _memoryCache[key] = value;
    try {
      if (value is String) {
        await MySharedPref.prefs.setString(key, value);
      } else if (value is bool) {
        await MySharedPref.prefs.setBool(key, value);
      } else if (value is int) {
        await MySharedPref.prefs.setInt(key, value);
      } else if (value is double) {
        await MySharedPref.prefs.setDouble(key, value);
      } else if (value is List<String>) {
        await MySharedPref.prefs.setStringList(key, value);
      } else {
        final jsonStr = jsonEncode(value);
        await MySharedPref.prefs.setString(key, jsonStr);
      }
    } catch (_) {}
  }

  // READ DATA
  static dynamic readCache(String key) {
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }
    try {
      final raw = MySharedPref.prefs.get(key);
      if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          _memoryCache[key] = decoded;
          return decoded;
        } catch (_) {
          return raw;
        }
      }
      return raw;
    } catch (_) {
      return null;
    }
  }
}

typedef MyGetStorage = AppStorageCache;
