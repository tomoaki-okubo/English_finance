class DailyActivity {
  final String dateKey; // "YYYY-MM-DD"
  final int drillCount;
  final int chatTurnCount;

  int get totalCount => drillCount + chatTurnCount;

  const DailyActivity({
    required this.dateKey,
    this.drillCount = 0,
    this.chatTurnCount = 0,
  });

  DailyActivity copyWith({
    String? dateKey,
    int? drillCount,
    int? chatTurnCount,
  }) {
    return DailyActivity(
      dateKey: dateKey ?? this.dateKey,
      drillCount: drillCount ?? this.drillCount,
      chatTurnCount: chatTurnCount ?? this.chatTurnCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'dateKey': dateKey,
    'drillCount': drillCount,
    'chatTurnCount': chatTurnCount,
  };

  factory DailyActivity.fromJson(Map<String, dynamic> json) => DailyActivity(
    dateKey: json['dateKey'] as String,
    drillCount: json['drillCount'] as int? ?? 0,
    chatTurnCount: json['chatTurnCount'] as int? ?? 0,
  );

  static String formatDateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
