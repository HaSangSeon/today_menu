class MenuItem {
  final String id;
  final String name;
  final String category;
  final String subCategory;
  final List<String> mealType;
  final int priceLevel;
  final String estimatedPrice;
  final int cookingTime;
  final bool spicy;
  final bool soup;
  final bool rice;
  final bool noodle;
  final bool meat;
  final bool healthy;
  final bool deliveryAvailable;
  final List<String> tags;

  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.mealType,
    required this.priceLevel,
    required this.estimatedPrice,
    required this.cookingTime,
    required this.spicy,
    required this.soup,
    required this.rice,
    required this.noodle,
    required this.meat,
    required this.healthy,
    required this.deliveryAvailable,
    required this.tags,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '기타',
      subCategory: json['subCategory'] as String? ?? '',
      mealType: (json['mealType'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      priceLevel: (json['priceLevel'] as num?)?.toInt() ?? 2,
      estimatedPrice: json['estimatedPrice'] as String? ?? '',
      cookingTime: (json['cookingTime'] as num?)?.toInt() ?? 15,
      spicy: json['spicy'] as bool? ?? false,
      soup: json['soup'] as bool? ?? false,
      rice: json['rice'] as bool? ?? false,
      noodle: json['noodle'] as bool? ?? false,
      meat: json['meat'] as bool? ?? false,
      healthy: json['healthy'] as bool? ?? false,
      deliveryAvailable: json['deliveryAvailable'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subCategory': subCategory,
      'mealType': mealType,
      'priceLevel': priceLevel,
      'estimatedPrice': estimatedPrice,
      'cookingTime': cookingTime,
      'spicy': spicy,
      'soup': soup,
      'rice': rice,
      'noodle': noodle,
      'meat': meat,
      'healthy': healthy,
      'deliveryAvailable': deliveryAvailable,
      'tags': tags,
    };
  }

  /// 각 음식 메뉴와 실제 음식 비주얼이 100% 직관적으로 매칭되는 정밀 이모지 매핑
  String get emoji {
    final n = name.toLowerCase();
    final sub = subCategory.toLowerCase();
    final cat = category.toLowerCase();

    // 1. 피자 & 버거 & 양식 대표
    if (n.contains('피자') || sub.contains('피자')) return '🍕';
    if (n.contains('버거') || sub.contains('버거') || n.contains('햄버거')) return '🍔';
    if (n.contains('핫도그')) return '🌭';
    if (n.contains('샌드위치') || n.contains('토스트') || n.contains('파니니')) return '🥪';
    if (n.contains('타코') || n.contains('부리또') || n.contains('퀘사디아') || n.contains('브리또')) return '🌮';
    if (n.contains('파스타') || n.contains('스파게티') || n.contains('라자냐') || n.contains('봉골레') || n.contains('까르보나라') || n.contains('알리오')) return '🍝';
    if (n.contains('스테이크') || n.contains('찹스테이크') || n.contains('립아이') || n.contains('티본') || n.contains('살치살')) return '🥩';

    // 2. 찌개 / 국 / 탕 / 뚝배기 / 국밥 / 전골류 (고기국물 포함)
    if (n.contains('찌개') || n.contains('된장') || n.contains('청국장') || n.contains('순두부') || n.contains('부대찌개') || n.contains('비지찌개') || n.contains('고추장찌개')) return '🍲';
    if (n.contains('국밥') || n.contains('해장국') || n.contains('설렁탕') || n.contains('곰탕') || n.contains('갈비탕') || n.contains('육개장') || n.contains('추어탕') || n.contains('감자탕') || n.contains('도가니탕') || n.contains('선지') || n.contains('내장탕') || n.contains('미역국') || n.contains('무국') || n.contains('북엇국') || n.contains('황태') || n.contains('삼계탕') || n.contains('백숙') || n.contains('닭한마리') || soup) return '🍲';
    if (n.contains('전골') || n.contains('샤브샤브') || n.contains('스키야키') || n.contains('밀푀유나베') || n.contains('훠궈') || n.contains('부대전골')) return '🥘';

    // 3. 치킨 & 닭 요리
    if (n.contains('치킨') || n.contains('통닭') || n.contains('닭강정') || n.contains('윙') || n.contains('봉') || n.contains('가라아게') || n.contains('너겟')) return '🍗';
    if (n.contains('닭발') || n.contains('불닭')) return '🌶️';
    if (n.contains('닭갈비') || n.contains('찜닭') || n.contains('닭볶음탕')) return '🥘';

    // 4. 면류 (국수/라면/짜장/짬뽕/우동/소바/쌀국수)
    if (n.contains('짜장') || n.contains('자장')) return '🥢';
    if (n.contains('짬뽕') || n.contains('마라탕') || n.contains('마라샹궈') || n.contains('탄탄면') || n.contains('우육면')) return '🍜';
    if (n.contains('라면') || n.contains('라멘') || n.contains('우동') || n.contains('국수') || n.contains('칼국수') || n.contains('쌀국수') || n.contains('모밀') || n.contains('소바') || n.contains('냉면') || n.contains('밀면') || n.contains('쫄면') || n.contains('비빔국수') || n.contains('잔치국수') || n.contains('콩국수') || n.contains('수제비') || noodle) return '🍜';

    // 5. 일식 & 초밥 & 해산물
    if (n.contains('초밥') || n.contains('스시') || n.contains('롤') || sub.contains('초밥')) return '🍣';
    if (n.contains('회') || n.contains('사시미') || n.contains('물회') || n.contains('연어') || n.contains('광어') || n.contains('참치') || n.contains('생선') || n.contains('고등어') || n.contains('갈치') || n.contains('장어') || n.contains('조기') || n.contains('삼치') || n.contains('굴비') || n.contains('장어덮밥') || n.contains('우나기')) return '🐟';
    if (n.contains('새우') || n.contains('감바스') || n.contains('쉬림프') || n.contains('간장새우') || n.contains('멘보샤')) return '🦐';
    if (n.contains('게') || n.contains('크랩') || n.contains('간장게장') || n.contains('양념게장') || n.contains('랍스터') || n.contains('랍스타')) return '🦀';
    if (n.contains('오징어') || n.contains('낙지') || n.contains('문어') || n.contains('쭈꾸미') || n.contains('타코야끼')) return '🐙';
    if (n.contains('조개') || n.contains('바지락') || n.contains('가리비') || n.contains('홍합') || n.contains('굴') || n.contains('전복')) return '🦪';
    if (n.contains('돈까스') || n.contains('돈가스') || n.contains('카츠') || n.contains('규카츠') || n.contains('치즈카츠') || n.contains('히레카츠') || n.contains('로스카츠')) return '🍱';

    // 6. 고기류 (삼겹살/갈비/불고기/수육/보쌈/족발/곱창)
    if (n.contains('족발') || n.contains('학센')) return '🍖';
    if (n.contains('보쌈') || n.contains('수육') || n.contains('차슈')) return '🥓';
    if (n.contains('삼겹살') || n.contains('베이컨') || n.contains('오겹살') || n.contains('항정살') || n.contains('목살') || n.contains('대패')) return '🥓';
    if (n.contains('갈비') || n.contains('불고기') || n.contains('양꼬치') || n.contains('바베큐') || n.contains('bbq') || n.contains('소고기') || n.contains('한우') || n.contains('곱창') || n.contains('대창') || n.contains('막창') || n.contains('등심') || n.contains('안심')) return '🥩';

    // 7. 만두 & 딤섬 & 중식
    if (n.contains('만두') || n.contains('교자') || n.contains('딤섬') || n.contains('샤오롱바오') || n.contains('군만두') || n.contains('물만두') || n.contains('쇼마이')) return '🥟';
    if (n.contains('탕수육') || n.contains('꿔바로우') || n.contains('유린기') || n.contains('깐풍기') || n.contains('동파육') || n.contains('고추잡채')) return '🥢';

    // 8. 분식 & 간식 & 길거리음식
    if (n.contains('떡볶이') || n.contains('라볶이') || n.contains('국물떡볶이') || n.contains('로제떡볶이')) return '🍢';
    if (n.contains('순대')) return '🍱';
    if (n.contains('튀김') || n.contains('어묵') || n.contains('오뎅') || n.contains('핫바') || n.contains('소떡소떡') || n.contains('김말이')) return '🍢';
    if (n.contains('김밥') || n.contains('주먹밥') || n.contains('삼각김밥') || n.contains('유부초밥')) return '🍙';

    // 9. 밥 / 덮밥 / 비빔밥 / 볶음밥 / 카레
    if (n.contains('카레') || n.contains('커리') || n.contains('하이라이스')) return '🍛';
    if (n.contains('비빔밥') || n.contains('돌솥')) return '🥣';
    if (n.contains('볶음밥') || n.contains('필라프') || n.contains('오므라이스') || n.contains('리조또') || n.contains('치밥')) return '🍳';
    if (n.contains('덮밥') || n.contains('돈부리') || n.contains('가츠동') || n.contains('규동') || n.contains('사케동') || n.contains('텐동') || n.contains('제육') || n.contains('오징어덮밥') || n.contains('낙지덮밥') || n.contains('마요덮밥')) return '🍱';
    if (n.contains('죽') || n.contains('전복죽') || n.contains('호박죽') || n.contains('팥죽')) return '🥣';
    if (n.contains('쌈밥') || n.contains('정식') || n.contains('백반') || n.contains('한정식') || n.contains('도시락')) return '🍱';

    // 10. 샐러드 & 건강식 & 디저트 / 베이커리
    if (n.contains('샐러드') || n.contains('포케') || n.contains('월남쌈') || n.contains('그릭요거트') || n.contains('다이어트') || healthy) return '🥗';
    if (n.contains('계란') || n.contains('오믈렛') || n.contains('프라이') || n.contains('에그')) return '🍳';
    if (n.contains('와플') || n.contains('크로플')) return '🧇';
    if (n.contains('팬케이크') || n.contains('수플레')) return '🥞';
    if (n.contains('빵') || n.contains('베이글') || n.contains('크루아상') || n.contains('바게트') || n.contains('소금빵')) return '🥐';
    if (n.contains('빙수') || n.contains('아이스크림') || n.contains('파르페')) return '🍨';

    // 11. 카테고리별 Fallback
    if (cat.contains('한식')) {
      if (meat) return '🥩';
      if (soup) return '🍲';
      if (rice) return '🍚';
      return '🍱';
    }
    if (cat.contains('중식')) return '🥟';
    if (cat.contains('일식')) return '🍣';
    if (cat.contains('양식')) return '🍝';
    if (cat.contains('분식')) return '🍢';
    if (cat.contains('아시안')) return '🍜';
    if (cat.contains('패스트푸드')) return '🍔';
    if (cat.contains('치킨')) return '🍗';
    if (cat.contains('피자')) return '🍕';
    if (cat.contains('샐러드') || cat.contains('다이어트')) return '🥗';

    if (rice) return '🍚';
    if (meat) return '🥩';
    if (soup) return '🍲';

    return '🍽️';
  }

  String get subtitleFormatted {
    final parts = <String>[category];
    if (subCategory.isNotEmpty && subCategory != category) {
      parts.add(subCategory);
    }
    if (mealType.isNotEmpty) {
      parts.add(mealType.first);
    }
    return parts.join(' · ');
  }
}
