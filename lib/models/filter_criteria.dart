class FilterCriteria {
  final String quickPreset; // 'none', 'lazy', 'delivery', 'budget', 'hangover', 'diet', 'spicy'
  final String mealType;
  final String price;
  final String category;
  final String cookingTime;
  final String preference;

  const FilterCriteria({
    this.quickPreset = 'none',
    this.mealType = '상관없음',
    this.price = '상관없음',
    this.category = '상관없음',
    this.cookingTime = '상관없음',
    this.preference = '아무거나',
  });

  bool get isDefault =>
      quickPreset == 'none' &&
      mealType == '상관없음' &&
      price == '상관없음' &&
      category == '상관없음' &&
      cookingTime == '상관없음' &&
      preference == '아무거나';

  FilterCriteria copyWith({
    String? quickPreset,
    String? mealType,
    String? price,
    String? category,
    String? cookingTime,
    String? preference,
  }) {
    return FilterCriteria(
      quickPreset: quickPreset ?? this.quickPreset,
      mealType: mealType ?? this.mealType,
      price: price ?? this.price,
      category: category ?? this.category,
      cookingTime: cookingTime ?? this.cookingTime,
      preference: preference ?? this.preference,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quickPreset': quickPreset,
      'mealType': mealType,
      'price': price,
      'category': category,
      'cookingTime': cookingTime,
      'preference': preference,
    };
  }

  factory FilterCriteria.fromJson(Map<String, dynamic> json) {
    return FilterCriteria(
      quickPreset: json['quickPreset'] as String? ?? 'none',
      mealType: json['mealType'] as String? ?? '상관없음',
      price: json['price'] as String? ?? '상관없음',
      category: json['category'] as String? ?? '상관없음',
      cookingTime: json['cookingTime'] as String? ?? '상관없음',
      preference: json['preference'] as String? ?? '아무거나',
    );
  }

  // 1인 가구 / 자취생 맞춤 퀵 프리셋 정의
  static const List<Map<String, String>> presets = [
    {
      'id': 'lazy',
      'emoji': '⚡',
      'label': '초간단 10분 컷',
      'desc': '귀찮음 극복 초스피드 요리',
    },
    {
      'id': 'delivery',
      'emoji': '🛵',
      'label': '혼밥 배달 맛집',
      'desc': '누워서 시켜먹는 1인 배달',
    },
    {
      'id': 'budget',
      'emoji': '🪙',
      'label': '지갑 지킴 갓성비',
      'desc': '5천원 이하 알뜰 한끼',
    },
    {
      'id': 'hangover',
      'emoji': '🍲',
      'label': '속풀리는 국물/해장',
      'desc': '얼큰하고 든든한 뚝배기',
    },
    {
      'id': 'spicy',
      'emoji': '🌶️',
      'label': '스트레스 타파 매운맛',
      'desc': '화끈하게 땡기는 매운 음식',
    },
    {
      'id': 'diet',
      'emoji': '🥗',
      'label': '클린 식단/다이어트',
      'desc': '가볍고 건강한 단백질 위주',
    },
  ];

  // 프리셋 적용 헬퍼
  static FilterCriteria fromPreset(String presetId) {
    switch (presetId) {
      case 'lazy':
        return const FilterCriteria(
          quickPreset: 'lazy',
          mealType: '집밥',
          cookingTime: '10분 이하',
          price: '상관없음',
          category: '상관없음',
          preference: '가볍게',
        );
      case 'delivery':
        return const FilterCriteria(
          quickPreset: 'delivery',
          mealType: '배달',
          cookingTime: '상관없음',
          price: '상관없음',
          category: '상관없음',
          preference: '든든하게',
        );
      case 'budget':
        return const FilterCriteria(
          quickPreset: 'budget',
          mealType: '집밥',
          price: '5천원 이하',
          cookingTime: '상관없음',
          category: '상관없음',
          preference: '아무거나',
        );
      case 'hangover':
        return const FilterCriteria(
          quickPreset: 'hangover',
          mealType: '상관없음',
          cookingTime: '상관없음',
          price: '상관없음',
          category: '국/찌개',
          preference: '국물',
        );
      case 'spicy':
        return const FilterCriteria(
          quickPreset: 'spicy',
          mealType: '상관없음',
          cookingTime: '상관없음',
          price: '상관없음',
          category: '상관없음',
          preference: '매운 음식',
        );
      case 'diet':
        return const FilterCriteria(
          quickPreset: 'diet',
          mealType: '상관없음',
          cookingTime: '상관없음',
          price: '상관없음',
          category: '샐러드',
          preference: '건강식',
        );
      default:
        return const FilterCriteria();
    }
  }

  // Filter options list for UI
  static const List<String> mealTypeOptions = [
    '상관없음',
    '집밥',
    '혼밥',
    '배달',
    '외식',
  ];

  static const List<String> priceOptions = [
    '상관없음',
    '5천원 이하',
    '1만원 이하',
    '1만5천원 이하',
  ];

  static const List<String> categoryOptions = [
    '상관없음',
    '한식',
    '분식',
    '양식',
    '일식',
    '중식',
    '패스트푸드',
    '치킨',
    '국/찌개',
    '면',
    '밥',
    '고기',
    '샐러드',
  ];

  static const List<String> cookingTimeOptions = [
    '상관없음',
    '10분 이하',
    '20분 이하',
    '30분 이하',
  ];

  static const List<String> preferenceOptions = [
    '아무거나',
    '든든하게',
    '가볍게',
    '매운 음식',
    '국물',
    '고기',
    '면',
    '밥',
    '건강식',
  ];
}
