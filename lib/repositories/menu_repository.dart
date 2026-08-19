import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/menu_item.dart';

abstract class MenuRepository {
  Future<List<MenuItem>> getAllMenus();
  Future<MenuItem?> getMenuById(String id);
  Future<List<MenuItem>> searchMenus(String query);
}

class LocalJsonMenuRepository implements MenuRepository {
  final String assetPath;
  List<MenuItem>? _cachedMenus;

  LocalJsonMenuRepository({
    this.assetPath = 'assets/data/menus.json',
  });

  // Constructor for testing with pre-loaded menu list
  LocalJsonMenuRepository.withMenus(List<MenuItem> menus)
      : assetPath = '',
        _cachedMenus = menus;

  @override
  Future<List<MenuItem>> getAllMenus() async {
    if (_cachedMenus != null) {
      return _cachedMenus!;
    }

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final dynamic decoded = json.decode(jsonString);
      if (decoded is List) {
        _cachedMenus = decoded
            .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
            .toList();
        return _cachedMenus!;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<MenuItem?> getMenuById(String id) async {
    final menus = await getAllMenus();
    try {
      return menus.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<MenuItem>> searchMenus(String query) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return [];

    final menus = await getAllMenus();
    return menus.where((menu) {
      final matchName = menu.name.toLowerCase().contains(trimmed);
      final matchCategory = menu.category.toLowerCase().contains(trimmed);
      final matchSubCategory = menu.subCategory.toLowerCase().contains(trimmed);
      final matchTags = menu.tags.any((tag) => tag.toLowerCase().contains(trimmed));
      return matchName || matchCategory || matchSubCategory || matchTags;
    }).toList();
  }
}
