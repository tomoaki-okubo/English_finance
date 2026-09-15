import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/daily_activity.dart';

class TrainingActivityState {
  final Map<String, DailyActivity> activities;
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final bool isLoading;

  const TrainingActivityState({
    required this.activities,
    required this.displayedMonth,
    required this.selectedDate,
    this.isLoading = false,
  });

  DailyActivity? get selectedDayActivity =>
      activities[DailyActivity.formatDateKey(selectedDate)];

  int get currentStreak {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey = DailyActivity.formatDateKey(today);
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayKey = DailyActivity.formatDateKey(yesterday);

    // If no activity today and no activity yesterday, streak is 0
    final hasToday = (activities[todayKey]?.totalCount ?? 0) > 0;
    final hasYesterday = (activities[yesterdayKey]?.totalCount ?? 0) > 0;

    if (!hasToday && !hasYesterday) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = hasToday ? today : yesterday;

    while (true) {
      final key = DailyActivity.formatDateKey(checkDate);
      final act = activities[key];
      if (act != null && act.totalCount > 0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int get activeDaysThisMonth {
    final y = displayedMonth.year;
    final m = displayedMonth.month;
    int count = 0;
    for (final act in activities.values) {
      if (act.totalCount > 0) {
        final parts = act.dateKey.split('-');
        if (parts.length == 3) {
          final actY = int.tryParse(parts[0]);
          final actM = int.tryParse(parts[1]);
          if (actY == y && actM == m) {
            count++;
          }
        }
      }
    }
    return count;
  }

  int get totalTrainingDays {
    return activities.values.where((e) => e.totalCount > 0).length;
  }

  int get totalActivitiesCount {
    return activities.values.fold<int>(0, (sum, e) => sum + e.totalCount);
  }

  TrainingActivityState copyWith({
    Map<String, DailyActivity>? activities,
    DateTime? displayedMonth,
    DateTime? selectedDate,
    bool? isLoading,
  }) {
    return TrainingActivityState(
      activities: activities ?? this.activities,
      displayedMonth: displayedMonth ?? this.displayedMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final trainingActivityControllerProvider =
    NotifierProvider<TrainingActivityController, TrainingActivityState>(() {
  return TrainingActivityController();
});

class TrainingActivityController extends Notifier<TrainingActivityState> {
  static const String boxName = 'training_activity';

  @override
  TrainingActivityState build() {
    final now = DateTime.now();
    scheduleMicrotask(() => _loadFromHive());
    return TrainingActivityState(
      activities: {},
      displayedMonth: DateTime(now.year, now.month, 1),
      selectedDate: DateTime(now.year, now.month, now.day),
      isLoading: true,
    );
  }

  Future<void> _loadFromHive() async {
    try {
      Box<String>? box;
      try {
        if (Hive.isBoxOpen(boxName)) {
          box = Hive.box<String>(boxName);
        } else {
          box = await Hive.openBox<String>(boxName);
        }
      } catch (_) {
        box = null;
      }

      if (box == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final map = <String, DailyActivity>{};
      for (final key in box.keys) {
        final raw = box.get(key);
        if (raw != null) {
          try {
            final json = jsonDecode(raw) as Map<String, dynamic>;
            map[key.toString()] = DailyActivity.fromJson(json);
          } catch (_) {}
        }
      }

      state = state.copyWith(activities: map, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveToHive(String dateKey, DailyActivity activity) async {
    try {
      Box<String>? box;
      try {
        if (Hive.isBoxOpen(boxName)) {
          box = Hive.box<String>(boxName);
        } else {
          box = await Hive.openBox<String>(boxName);
        }
      } catch (_) {
        box = null;
      }

      if (box != null) {
        await box.put(dateKey, jsonEncode(activity.toJson()));
      }
    } catch (_) {}
  }

  /// Record training activity (called when answering drills or chatting)
  Future<void> recordActivity({int drills = 0, int chatTurns = 0}) async {
    final now = DateTime.now();
    final todayKey = DailyActivity.formatDateKey(now);
    final current = state.activities[todayKey] ?? DailyActivity(dateKey: todayKey);

    final updated = current.copyWith(
      drillCount: current.drillCount + drills,
      chatTurnCount: current.chatTurnCount + chatTurns,
    );

    final newMap = Map<String, DailyActivity>.from(state.activities);
    newMap[todayKey] = updated;

    state = state.copyWith(activities: newMap);
    await _saveToHive(todayKey, updated);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void changeMonth(int monthOffset) {
    final current = state.displayedMonth;
    final newMonth = DateTime(current.year, current.month + monthOffset, 1);
    state = state.copyWith(displayedMonth: newMonth);
  }

  void goToToday() {
    final now = DateTime.now();
    state = state.copyWith(
      displayedMonth: DateTime(now.year, now.month, 1),
      selectedDate: DateTime(now.year, now.month, now.day),
    );
  }

  Future<void> clearAll() async {
    state = state.copyWith(activities: {});
    try {
      Box<String>? box;
      if (Hive.isBoxOpen(boxName)) {
        box = Hive.box<String>(boxName);
      } else {
        box = await Hive.openBox<String>(boxName);
      }
      await box.clear();
    } catch (_) {}
  }
}
