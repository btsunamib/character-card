import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_config_model.dart';
import '../models/character_card_model.dart';
import '../../core/errors/exceptions.dart';

abstract class LocalDataSource {
  Future<AppConfig> getConfig();
  Future<void> saveConfig(AppConfig config);
  Future<List<CharacterCard>> getHistory();
  Future<void> saveToHistory(CharacterCard card);
  Future<void> deleteFromHistory(String id);
  Future<void> clearHistory();
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences _prefs;

  static const String _configKey = 'app_config';
  static const String _historyKey = 'character_history';
  static const int _maxHistoryItems = 50;

  LocalDataSourceImpl(this._prefs);

  @override
  Future<AppConfig> getConfig() async {
    try {
      final jsonString = _prefs.getString(_configKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        return AppConfig.fromJson(json);
      }
      return const AppConfig();
    } catch (e) {
      throw Exception(Exceptions.cacheException);
    }
  }

  @override
  Future<void> saveConfig(AppConfig config) async {
    try {
      final jsonString = jsonEncode(config.toJson());
      await _prefs.setString(_configKey, jsonString);
    } catch (e) {
      throw Exception(Exceptions.cacheException);
    }
  }

  @override
  Future<List<CharacterCard>> getHistory() async {
    try {
      final jsonString = _prefs.getString(_historyKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList
            .map((json) => CharacterCard.fromJson(json))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      return [];
    } catch (e) {
      throw Exception(Exceptions.cacheException);
    }
  }

  @override
  Future<void> saveToHistory(CharacterCard card) async {
    try {
      final history = await getHistory();
      history.insert(0, card);

      final trimmedHistory = history.take(_maxHistoryItems).toList();
      final jsonString = jsonEncode(trimmedHistory.map((c) => c.toJson()).toList());
      await _prefs.setString(_historyKey, jsonString);
    } catch (e) {
      throw Exception(Exceptions.cacheException);
    }
  }

  @override
  Future<void> deleteFromHistory(String id) async {
    try {
      final history = await getHistory();
      history.removeWhere((card) => card.id == id);
      final jsonString = jsonEncode(history.map((c) => c.toJson()).toList());
      await _prefs.setString(_historyKey, jsonString);
    } catch (e) {
      throw Exception(Exceptions.cacheException);
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await _prefs.remove(_historyKey);
    } catch (e) {
      throw Exception(Exceptions.cacheException);
    }
  }
}
