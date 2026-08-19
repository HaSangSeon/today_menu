class FilterCriteria {
  final String mealType;
  final String price;
  final String category;
  final String cookingTime;
  final String preference;

  const FilterCriteria({
    this.mealType = '상관없음',
    this.price = '상관없음',
    this.category = '상관없음',
    this.cookingTime = '상관없음',
    this.preference = '아무거나',
  });

  bool get isDefault =>
      mealType == '상관없음' &&
      price == '상관없음' &&
      category == '상관없음' &&
      cookingTime == '상관없음' &&
      preference == '아무거나';

  FilterCriteria copyWith({
    String? mealType,
    String? price,
    String? category,
    String? cookingTime,
    String? preference,
  }) {
    return FilterCriteria(
      mealType: mealType ?? this.mealType,
      price: price ?? this.price,
      category: category ?? this.category,
      cookingTime: cookingTime ?? this.cookingTime,
      preference: preference ?? this.preference,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealType': mealType,
      'price': price,
      'category': category,
      'cookingTime': cookingTime,
      'preference': preference,
    };
  }

  factory FilterCriteria.fromJson(Map<String, dynamic> json) {
    return FilterCriteria(
      mealType: json['mealType'] as String? ?? '상관없음',
      price: json['price'] as String? ?? '상관없음',
      category: json['category'] as String? ?? '상관없음',
      cookingTime: json['cookingTime'] as String? ?? '상관없음',
      preference: json['preference'] as String? ?? '아무거나',
    );
  }

  // Filter options list for UI
  static const List<String> mealTypeOptions = [
    '상관없음',
    '혼밥',
    '집밥',
    '외식',
    '배달',
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
    '중식',
    '일식',
    '양식',
    '분식',
    '패스트푸드',
    '치킨',
    '면',
    '밥',
    '국/찌개',
    '고기',
    '기타',
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
    '면',
    '밥',
    '고기',
    '건강식',
  ];
}
