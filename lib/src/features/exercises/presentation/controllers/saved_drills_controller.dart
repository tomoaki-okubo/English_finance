import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/saved_drill_item.dart';
import '../../domain/entities/drill_question.dart';

class SavedDrillsState {
  final List<SavedDrillItem> items;
  final bool isLoading;

  const SavedDrillsState({
    required this.items,
    this.isLoading = false,
  });

  List<SavedDrillItem> get mistakes => items.where((e) => e.isMistake).toList();
  List<SavedDrillItem> get bookmarks => items.where((e) => e.isBookmarked).toList();

  SavedDrillsState copyWith({
    List<SavedDrillItem>? items,
    bool? isLoading,
  }) {
    return SavedDrillsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final savedDrillsControllerProvider = NotifierProvider<SavedDrillsController, SavedDrillsState>(() {
  return SavedDrillsController();
});

class SavedDrillsController extends Notifier<SavedDrillsState> {
  static const String boxName = 'saved_drills';

  @override
  SavedDrillsState build() {
    scheduleMicrotask(() => _loadFromHive());
    return const SavedDrillsState(items: [], isLoading: true);
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

      final items = <SavedDrillItem>[];
      for (final raw in box.values) {
        try {
          items.add(SavedDrillItem.fromJson(raw));
        } catch (_) {}
      }

      items.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      state = state.copyWith(items: items, isLoading: false);
    } catch (_) {
      state = state.copyWith(items: [], isLoading: false);
    }
  }

  Future<void> _saveToHive() async {
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

      if (box == null) return;

      await box.clear();
      for (final item in state.items) {
        await box.put(item.id, item.toJson());
      }
    } catch (_) {}
  }

  /// Automatically record a mistaken question
  Future<void> saveMistake({
    required DrillQuestion drill,
    required String userAnswer,
  }) async {
    final existingIndex = state.items.indexWhere((e) => e.question == drill.question);

    List<SavedDrillItem> updatedList;
    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final updated = existing.copyWith(
        userAnswer: userAnswer,
        isMistake: true,
        savedAt: DateTime.now(),
      );
      updatedList = List<SavedDrillItem>.from(state.items)..[existingIndex] = updated;
    } else {
      final newItem = SavedDrillItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: drill.category,
        topic: drill.topic,
        question: drill.question,
        options: drill.options,
        correctIndex: drill.correctIndex,
        explanation: drill.explanation,
        userAnswer: userAnswer,
        isMistake: true,
        isBookmarked: false,
        savedAt: DateTime.now(),
        translation: drill.translation,
      );
      updatedList = [newItem, ...state.items];
    }

    state = state.copyWith(items: updatedList);
    await _saveToHive();
  }

  /// Toggle bookmark for any question
  Future<bool> toggleBookmark(DrillQuestion drill) async {
    final existingIndex = state.items.indexWhere((e) => e.question == drill.question);

    List<SavedDrillItem> updatedList;
    bool newBookmarkedState;

    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      newBookmarkedState = !existing.isBookmarked;

      if (!newBookmarkedState && !existing.isMistake) {
        updatedList = List<SavedDrillItem>.from(state.items)..removeAt(existingIndex);
      } else {
        final updated = existing.copyWith(
          isBookmarked: newBookmarkedState,
          savedAt: DateTime.now(),
        );
        updatedList = List<SavedDrillItem>.from(state.items)..[existingIndex] = updated;
      }
    } else {
      newBookmarkedState = true;
      final newItem = SavedDrillItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: drill.category,
        topic: drill.topic,
        question: drill.question,
        options: drill.options,
        correctIndex: drill.correctIndex,
        explanation: drill.explanation,
        isMistake: false,
        isBookmarked: true,
        savedAt: DateTime.now(),
        translation: drill.translation,
      );
      updatedList = [newItem, ...state.items];
    }

    state = state.copyWith(items: updatedList);
    await _saveToHive();
    return newBookmarkedState;
  }

  bool isBookmarked(String question) {
    return state.items.any((e) => e.question == question && e.isBookmarked);
  }

  bool isMistake(String question) {
    return state.items.any((e) => e.question == question && e.isMistake);
  }

  Future<void> removeItem(String id) async {
    final updatedList = state.items.where((e) => e.id != id).toList();
    state = state.copyWith(items: updatedList);
    await _saveToHive();
  }

  Future<void> markAsMastered(String id) async {
    final index = state.items.indexWhere((e) => e.id == id);
    if (index < 0) return;

    final item = state.items[index];
    List<SavedDrillItem> updatedList;
    if (item.isBookmarked) {
      final updated = item.copyWith(isMistake: false);
      updatedList = List<SavedDrillItem>.from(state.items)..[index] = updated;
    } else {
      updatedList = List<SavedDrillItem>.from(state.items)..removeAt(index);
    }

    state = state.copyWith(items: updatedList);
    await _saveToHive();
  }

  Future<void> clearAll() async {
    state = state.copyWith(items: []);
    await _saveToHive();
  }
}
