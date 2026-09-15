import 'dart:async';
import 'package:hive/hive.dart';
import '../../domain/entities/flashcard.dart';

/// Hive-backed repository for flashcard persistence (user cards, AI cards, and review state).
class FlashcardRepository {
  static const String _userCardsBoxName = 'flashcard_user_cards';
  static const String _reviewStateBoxName = 'flashcard_review_state';
  static const String _deletedCardIdsBoxName = 'flashcard_deleted_ids';

  /// Load all user-created and AI-generated cards from Hive
  Future<List<Flashcard>> loadUserCards() async {
    final box = await _openBox(_userCardsBoxName);
    final cards = <Flashcard>[];
    for (final raw in box.values) {
      try {
        cards.add(Flashcard.fromJson(raw));
      } catch (_) {}
    }
    return cards;
  }

  /// Load set of deleted card IDs
  Future<Set<String>> loadDeletedCardIds() async {
    final box = await _openBox(_deletedCardIdsBoxName);
    return box.values.toSet();
  }

  /// Save a user-created or AI-generated card
  Future<void> saveCard(Flashcard card) async {
    final box = await _openBox(_userCardsBoxName);
    await box.put(card.id, card.toJson());
  }

  /// Delete a card by ID
  Future<void> deleteCard(String id) async {
    await deleteCards([id]);
  }

  /// Bulk delete cards by ID
  Future<void> deleteCards(List<String> ids) async {
    final userBox = await _openBox(_userCardsBoxName);
    final deletedBox = await _openBox(_deletedCardIdsBoxName);
    for (final id in ids) {
      await userBox.delete(id);
      await deletedBox.put(id, id);
    }
  }

  /// Clear all stored user cards, review states, and deleted card IDs from Hive
  Future<void> clearAll() async {
    final userBox = await _openBox(_userCardsBoxName);
    await userBox.clear();

    final reviewBox = await _openBox(_reviewStateBoxName);
    await reviewBox.clear();

    final deletedBox = await _openBox(_deletedCardIdsBoxName);
    await deletedBox.clear();
  }

  /// Load review state for all cards (keyed by card id)
  Future<Map<String, Flashcard>> loadReviewStates() async {
    final box = await _openBox(_reviewStateBoxName);
    final states = <String, Flashcard>{};
    for (final key in box.keys) {
      try {
        states[key as String] = Flashcard.fromJson(box.get(key)!);
      } catch (_) {}
    }
    return states;
  }

  /// Persist review state for a single card
  Future<void> saveReviewState(Flashcard card) async {
    final box = await _openBox(_reviewStateBoxName);
    await box.put(card.id, card.toJson());
  }

  /// Bulk save review states (e.g., after a session)
  Future<void> saveAllReviewStates(List<Flashcard> cards) async {
    final box = await _openBox(_reviewStateBoxName);
    for (final card in cards) {
      await box.put(card.id, card.toJson());
    }
  }

  /// Get statistics
  Future<Map<String, int>> getStatistics() async {
    final states = await loadReviewStates();
    int mastered = 0;
    int learning = 0;
    int newCards = 0;
    int totalReviews = 0;

    for (final card in states.values) {
      switch (card.status) {
        case FlashcardStatus.mastered:
          mastered++;
          break;
        case FlashcardStatus.learning:
          learning++;
          break;
        case FlashcardStatus.newCard:
          newCards++;
          break;
      }
      totalReviews += card.reviewCount;
    }

    return {
      'mastered': mastered,
      'learning': learning,
      'new': newCards,
      'totalReviews': totalReviews,
    };
  }

  Future<Box<String>> _openBox(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<String>(name);
    }
    return Hive.openBox<String>(name);
  }
}
