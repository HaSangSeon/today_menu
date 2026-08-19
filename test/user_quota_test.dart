import 'package:flutter_test/flutter_test.dart';
import 'package:today_menu/config/app_config.dart';
import 'package:today_menu/models/meal_history_item.dart';
import 'package:today_menu/models/user_quota.dart';

void main() {
  group('UserQuota & MealHistory Tests', () {
    test('초기 UserQuota는 dailyFreeLimit(100회)를 가진다', () {
      final quota = UserQuota.initial();
      expect(quota.remainingCount, AppConfig.dailyFreeLimit);
      expect(quota.totalBonusEarnedToday, 0);
    });

    test('추천 시 횟수가 1회씩 차감되며 0 이하로는 내려가지 않는다', () {
      var quota = UserQuota.initial();
      expect(quota.remainingCount, 100);

      quota = quota.decrement();
      expect(quota.remainingCount, 99);

      // 100회 초과 차감
      for (int i = 0; i < 110; i++) {
        quota = quota.decrement();
      }
      expect(quota.remainingCount, 0);
    });

    test('보상형 광고 시청 시 +10회가 안전하게 지급된다', () {
      var quota = UserQuota.initial();
      quota = quota.addBonus(AppConfig.rewardAdditionalCount);

      expect(quota.remainingCount, AppConfig.dailyFreeLimit + 10);
      expect(quota.totalBonusEarnedToday, 10);
    });

    test('날짜가 변경되면 자동으로 100회로 리셋된다', () {
      // 과거 날짜의 0회 소진 상태 quota
      final yesterdayQuota = const UserQuota(
        remainingCount: 0,
        lastDate: '2026-01-01',
        totalBonusEarnedToday: 5,
      );

      final resetQuota = yesterdayQuota.checkAndResetDaily();
      expect(resetQuota.remainingCount, AppConfig.dailyFreeLimit);
      expect(resetQuota.totalBonusEarnedToday, 0);
      expect(resetQuota.lastDate, UserQuota.todayString);
    });

    test('MealHistoryItem 포맷팅 검증 (날짜 및 시간)', () {
      final historyItem = MealHistoryItem(
        id: 'hist_01',
        menuId: 'menu_01',
        menuName: '김치찌개',
        category: '한식',
        emoji: '🍲',
        decidedAt: DateTime(2026, 8, 19, 15, 30),
      );

      expect(historyItem.formattedDate, '8월 19일');
      expect(historyItem.formattedDateTime, '8월 19일 오후 3:30');
      expect(historyItem.menuName, '김치찌개');
    });
  });
}
