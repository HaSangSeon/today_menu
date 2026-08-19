class MealHistoryItem {
  final String id;
  final String menuId;
  final String menuName;
  final String category;
  final String emoji;
  final DateTime decidedAt;

  const MealHistoryItem({
    required this.id,
    required this.menuId,
    required this.menuName,
    required this.category,
    required this.emoji,
    required this.decidedAt,
  });

  String get formattedDate {
    return '${decidedAt.month}월 ${decidedAt.day}일';
  }

  String get formattedDateTime {
    final period = decidedAt.hour < 12 ? '오전' : '오후';
    final hour = decidedAt.hour % 12 == 0 ? 12 : decidedAt.hour % 12;
    final minute = decidedAt.minute.toString().padLeft(2, '0');
    return '${decidedAt.month}월 ${decidedAt.day}일 $period $hour:$minute';
  }

  factory MealHistoryItem.fromJson(Map<String, dynamic> json) {
    return MealHistoryItem(
      id: json['id'] as String? ?? '',
      menuId: json['menuId'] as String? ?? '',
      menuName: json['menuName'] as String? ?? '',
      category: json['category'] as String? ?? '한식',
      emoji: json['emoji'] as String? ?? '🍽️',
      decidedAt: json['decidedAt'] != null
          ? DateTime.tryParse(json['decidedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuId': menuId,
      'menuName': menuName,
      'category': category,
      'emoji': emoji,
      'decidedAt': decidedAt.toIso8601String(),
    };
  }
}
