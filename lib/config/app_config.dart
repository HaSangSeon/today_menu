import 'dart:io';

class AppConfig {
  static const String appName = '오늘 뭐 먹지? · 결정장애 해결소';
  static const String appTagline = '오늘 뭐 먹지? 1초 만에 딱 골라드려요';

  // 일일 무료 추천 횟수 및 광고 보상 (개발/테스트 100회 지원)
  static const int dailyFreeLimit = 100;
  static const int rewardAdditionalCount = 10;
  static const int maxHistoryCount = 30;
  static const int maxRecentExclusions = 5;

  // Google AdMob 테스트 광고 ID (개발 및 테스트용)
  // Android Test IDs
  static const String androidBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String androidRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

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
