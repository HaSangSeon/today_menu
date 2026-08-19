import '../config/app_config.dart';

class UserQuota {
  final int remainingCount;
  final String lastDate; // YYYY-MM-DD
  final int totalBonusEarnedToday;

  const UserQuota({
    required this.remainingCount,
    required this.lastDate,
    this.totalBonusEarnedToday = 0,
  });

  static String get todayString {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  factory UserQuota.initial() {
    return UserQuota(
      remainingCount: AppConfig.dailyFreeLimit,
      lastDate: todayString,
      totalBonusEarnedToday: 0,
    );
  }

  UserQuota checkAndResetDaily() {
    final currentToday = todayString;
    if (lastDate != currentToday) {
      return UserQuota(
        remainingCount: AppConfig.dailyFreeLimit,
        lastDate: currentToday,
        totalBonusEarnedToday: 0,
      );
    }
    return this;
  }

  UserQuota decrement() {
    final current = checkAndResetDaily();
    final newCount = current.remainingCount > 0 ? current.remainingCount - 1 : 0;
    return UserQuota(
      remainingCount: newCount,
      lastDate: current.lastDate,
      totalBonusEarnedToday: current.totalBonusEarnedToday,
    );
  }

  UserQuota addBonus(int count) {
    final current = checkAndResetDaily();
    return UserQuota(
      remainingCount: current.remainingCount + count,
      lastDate: current.lastDate,
      totalBonusEarnedToday: current.totalBonusEarnedToday + count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remainingCount': remainingCount,
      'lastDate': lastDate,
      'totalBonusEarnedToday': totalBonusEarnedToday,
    };
  }

  factory UserQuota.fromJson(Map<String, dynamic> json) {
    return UserQuota(
      remainingCount:
          (json['remainingCount'] as num?)?.toInt() ?? AppConfig.dailyFreeLimit,
      lastDate: json['lastDate'] as String? ?? todayString,
      totalBonusEarnedToday:
          (json['totalBonusEarnedToday'] as num?)?.toInt() ?? 0,
    ).checkAndResetDaily();
  }
}
