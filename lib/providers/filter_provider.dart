import 'package:flutter/foundation.dart';
import '../models/filter_criteria.dart';
import '../repositories/local_storage_repository.dart';

class FilterProvider extends ChangeNotifier {
  final LocalStorageRepository _storageRepository;
  FilterCriteria _criteria = const FilterCriteria();

  FilterProvider(this._storageRepository);

  FilterCriteria get criteria => _criteria;

  Future<void> initialize() async {
    _criteria = await _storageRepository.loadSavedFilter();
    notifyListeners();
  }

  void togglePreset(String presetId) {
    if (_criteria.quickPreset == presetId) {
      _criteria = const FilterCriteria();
    } else {
      _criteria = FilterCriteria.fromPreset(presetId);
    }
    _save();
  }

  void updateMealType(String mealType) {
    _criteria = _criteria.copyWith(
      mealType: mealType,
      quickPreset: 'none',
    );
    _save();
  }

  void updatePrice(String price) {
    _criteria = _criteria.copyWith(
      price: price,
      quickPreset: 'none',
    );
    _save();
  }

  void updateCategory(String category) {
    _criteria = _criteria.copyWith(
      category: category,
      quickPreset: 'none',
    );
    _save();
  }

  void updateCookingTime(String cookingTime) {
    _criteria = _criteria.copyWith(
      cookingTime: cookingTime,
      quickPreset: 'none',
    );
    _save();
  }

  void updatePreference(String preference) {
    _criteria = _criteria.copyWith(
      preference: preference,
      quickPreset: 'none',
    );
    _save();
  }

  void resetFilter() {
    _criteria = const FilterCriteria();
    _save();
  }

  void _save() {
    notifyListeners();
    _storageRepository.saveFilter(_criteria);
  }
}
