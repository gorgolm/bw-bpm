import 'dart:convert';

import 'package:bw_pm/config/logger/flogger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService({required SharedPreferencesAsync preferences}) : _preferences = preferences;

  final SharedPreferencesAsync _preferences;

  Future<void> save<T>(String key, T value) async {
    if (value is String) {
      await _preferences.setString(key, value);
    } else if (value is int) {
      await _preferences.setInt(key, value);
    } else if (value is bool) {
      await _preferences.setBool(key, value);
    } else if (value is double) {
      await _preferences.setDouble(key, value);
    } else if (value is List<String>) {
      await _preferences.setStringList(key, value);
    } else {
      return Flogger.e("Unsupported type: $T can't be saved. Use `saveObject` instead.");
    }
  }

  Future<T?> get<T>(String key) async {
    final dynamic result;
    if (T == String) {
      result = await _preferences.getString(key);
    } else if (T == int) {
      result = await _preferences.getInt(key);
    } else if (T == double) {
      result = await _preferences.getDouble(key);
    } else if (T == bool) {
      result = await _preferences.getBool(key);
    } else if (T == List<String>) {
      result = await _preferences.getStringList(key);
    } else {
      Flogger.e("Unsupported type: $T can't be retrieved. Use `getObject` instead.");
      return null;
    }

    return result as T?;
  }

  Future<void> delete(String key) async {
    await _preferences.remove(key);
  }

  Future<void> saveObject<T>(String key, Map<String, dynamic> Function() toJson) async {
    final jsonString = jsonEncode(toJson());
    await _preferences.setString(key, jsonString);
  }

  Future<T?> getObject<T>(String key, T Function(Map<String, dynamic> json) fromJson) async {
    try {
      final jsonString = await _preferences.getString(key);
      if (jsonString == null) return null;
      final jsonMap = (jsonDecode(jsonString)) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } on Exception catch (_) {
      Flogger.e('Failed to retrieve object from shared preferences for key: $key');
      return null;
    }
  }
}
