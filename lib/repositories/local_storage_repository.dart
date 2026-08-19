import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/filter_criteria.dart';
import '../models/meal_history_item.dart';
import '../models/user_quota.dart';

abstract class LocalStorageRepository {
  Future<UserQuota> loadUserQuota();
  Future<void> saveUserQuota(UserQuota quota);

  Future<List<String>> loadRecentRecommendedIds();
  Future<void> saveRecentRecommendedIds(List<String> ids);

  Future<List<MealHistoryItem>> loadMealHistory();
  Future<void> saveMealHistory(List<MealHistoryItem> history);
  Future<void> addMealToHistory(MealHistoryItem item);

  Future<FilterCriteria> loadSavedFilter();
  Future<void> saveFilter(FilterCriteria filter);
}

class SharedPreferencesLocalStorageRepository implements LocalStorageRepository {
  static const String _keyQuota = 'user_quota_v1';
  static const String _keyRecentIds = 'recent_recommended_ids_v1';
  static const String _keyMealHistory = 'meal_history_v1';
  static const String _keySavedFilter = 'saved_filter_v1';

  final SharedPreferences? _prefsInstance;

  SharedPreferencesLocalStorageRepository([this._prefsInstance]);

  Future<SharedPreferences> _getPrefs() async {
    if (_prefsInstance != null) {
      return _prefsInstance;
    }
    return await SharedPreferences.getInstance();
  }

  @override
  Future<UserQuota> loadUserQuota() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_keyQuota);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic>) {
          return UserQuota.fromJson(decoded);
        }
      } catch (_) {}
    }
    return UserQuota.initial();
  }

  @override
  Future<void> saveUserQuota(UserQuota quota) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyQuota, json.encode(quota.toJson()));
  }

  @override
  Future<List<String>> loadRecentRecommendedIds() async {
    final prefs = await _getPrefs();
    final list = prefs.getStringList(_keyRecentIds);
    return list ?? [];
  }

  @override
  Future<void> saveRecentRecommendedIds(List<String> ids) async {
    final prefs = await _getPrefs();
    // Keep only recent N items
    final truncated = ids.length > AppConfig.maxRecentExclusions
        ? ids.sublist(ids.length - AppConfig.maxRecentExclusions)
        : ids;
    await prefs.setStringList(_keyRecentIds, truncated);
  }

  @override
  Future<List<MealHistoryItem>> loadMealHistory() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_keyMealHistory);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final decoded = json.decode(jsonString);
        if (decoded is List) {
          return decoded
              .map((item) =>
                  MealHistoryItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<void> saveMealHistory(List<MealHistoryItem> history) async {
    final prefs = await _getPrefs();
    final truncated = history.length > AppConfig.maxHistoryCount
        ? history.sublist(0, AppConfig.maxHistoryCount)
        : history;
    final jsonList = truncated.map((item) => item.toJson()).toList();
    await prefs.setString(_keyMealHistory, json.encode(jsonList));
  }

  @override
  Future<void> addMealToHistory(MealHistoryItem item) async {
    final current = await loadMealHistory();
    // Insert newest at beginning
    final updated = [item, ...current.where((e) => e.id != item.id)];
    await saveMealHistory(updated);
  }

  @override
  Future<FilterCriteria> loadSavedFilter() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_keySavedFilter);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic>) {
          return FilterCriteria.fromJson(decoded);
        }
      } catch (_) {}
    }
    return const FilterCriteria();
  }

  @override
  Future<void> saveFilter(FilterCriteria filter) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keySavedFilter, json.encode(filter.toJson()));
  }
}
