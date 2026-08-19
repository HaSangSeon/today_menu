import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/filter_criteria.dart';
import '../models/meal_history_item.dart';
import '../models/menu_item.dart';
import '../models/user_quota.dart';
import '../repositories/local_storage_repository.dart';
import '../repositories/menu_repository.dart';
import '../services/recommendation_engine.dart';

class MenuProvider extends ChangeNotifier {
  final MenuRepository menuRepository;
  final LocalStorageRepository storageRepository;
  final RecommendationEngine _engine;

  List<MenuItem> _allMenus = [];
  RecommendationResult? _currentRecommendation;
  List<String> _recentRecommendedIds = [];
  List<MealHistoryItem> _mealHistory = [];
  UserQuota _userQuota = UserQuota.initial();
  bool _isLoading = false;

  MenuProvider({
    required this.menuRepository,
    required this.storageRepository,
    RecommendationEngine? engine,
  }) : _engine = engine ?? RecommendationEngine();

  List<MenuItem> get allMenus => _allMenus;
  RecommendationResult? get currentRecommendation => _currentRecommendation;
  List<MealHistoryItem> get mealHistory => _mealHistory;
  UserQuota get userQuota => _userQuota;
  bool get isLoading => _isLoading;
  int get remainingQuota => _userQuota.remainingCount;
  bool get hasQuota => _userQuota.remainingCount > 0;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _allMenus = await menuRepository.getAllMenus();
    _userQuota = await storageRepository.loadUserQuota();
    _recentRecommendedIds = await storageRepository.loadRecentRecommendedIds();
    _mealHistory = await storageRepository.loadMealHistory();

    _isLoading = false;
    notifyListeners();
  }

  /// 새로운 메뉴 추천 실행
  bool recommendMenu(FilterCriteria filter) {
    _userQuota = _userQuota.checkAndResetDaily();

    if (!hasQuota) {
      notifyListeners();
      return false; // Quota exhausted
    }

    // 추천 횟수 1회 차감
    _userQuota = _userQuota.decrement();
    storageRepository.saveUserQuota(_userQuota);

    // 추천 알고리즘 실행
    final result = _engine.recommend(
      allMenus: _allMenus,
      filter: filter,
      recentExcludedIds: _recentRecommendedIds,
    );

    if (result != null) {
      _currentRecommendation = result;

      // 최근 5개 추천 목록에 추가
      _recentRecommendedIds.add(result.menuItem.id);
      if (_recentRecommendedIds.length > AppConfig.maxRecentExclusions) {
        _recentRecommendedIds.removeAt(0);
      }
      storageRepository.saveRecentRecommendedIds(_recentRecommendedIds);
    }

    notifyListeners();
    return true;
  }

  /// 오늘의 메뉴 최종 확정
  Future<void> confirmCurrentMenu() async {
    if (_currentRecommendation == null) return;

    final item = _currentRecommendation!.menuItem;
    final historyItem = MealHistoryItem(
      id: '${item.id}_${DateTime.now().millisecondsSinceEpoch}',
      menuId: item.id,
      menuName: item.name,
      category: item.category,
      emoji: item.emoji,
      decidedAt: DateTime.now(),
    );

    _mealHistory = [historyItem, ..._mealHistory];
    if (_mealHistory.length > AppConfig.maxHistoryCount) {
      _mealHistory = _mealHistory.sublist(0, AppConfig.maxHistoryCount);
    }

    await storageRepository.saveMealHistory(_mealHistory);
    notifyListeners();
  }

  /// 개별 기록 삭제
  Future<void> deleteMealHistoryItem(String id) async {
    _mealHistory.removeWhere((item) => item.id == id);
    await storageRepository.saveMealHistory(_mealHistory);
    notifyListeners();
  }

  /// 전체 기록 삭제
  Future<void> clearAllMealHistory() async {
    _mealHistory.clear();
    await storageRepository.saveMealHistory(_mealHistory);
    notifyListeners();
  }

  /// 보상형 광고 시청 후 추천 횟수 +3회 추가
  Future<void> addRewardBonus() async {
    _userQuota = _userQuota.addBonus(AppConfig.rewardAdditionalCount);
    await storageRepository.saveUserQuota(_userQuota);
    notifyListeners();
  }

  /// 검색 기능
  Future<List<MenuItem>> searchMenus(String query) async {
    return menuRepository.searchMenus(query);
  }
}
