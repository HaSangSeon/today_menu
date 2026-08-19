import 'dart:io';

class AppConfig {
  static const String appName = '오늘 뭐 먹지? · 결정장애 해결소';
  static const String appTagline = '오늘 뭐 먹지? 1초 만에 딱 골라드려요';

  // 일일 무료 추천 횟수 및 광고 보상 (기본 3회, 광고 시 +3회 충전)
  static const int dailyFreeLimit = 3;
  static const int rewardAdditionalCount = 3;
  static const int maxHistoryCount = 30;
  static const int maxRecentExclusions = 5;

  // Android AdMob IDs
  static const String androidBannerAdUnitId =
      'ca-app-pub-3702899361747571/2599070103';
  static const String androidRewardedAdUnitId =
      'ca-app-pub-3702899361747571/3206303713';

  // iOS Test IDs
  static const String iosBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String iosRewardedAdUnitId =
      'ca-app-pub-3940256099942544/1712485313';

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return iosBannerAdUnitId;
    }
    return androidBannerAdUnitId;
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return androidRewardedAdUnitId;
    } else if (Platform.isIOS) {
      return iosRewardedAdUnitId;
    }
    return androidRewardedAdUnitId;
  }
}
