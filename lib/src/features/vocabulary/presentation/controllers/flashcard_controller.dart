import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/flashcard.dart';
import '../../data/sources/flashcard_seeds_data.dart';
import '../../data/repositories/flashcard_repository.dart';

// --- State ---

class FlashcardState {
  final List<Flashcard> allCards;
  final List<Flashcard> sessionDeck;
  final int sessionIndex;
  final Map<int, bool> sessionAnswers; // key: index in sessionDeck, val: true(known)/false(unknown)
  final bool isLoading;
  final String? selectedCategory;
  final FlashcardSessionMode mode;

  const FlashcardState({
    this.allCards = const [],
    this.sessionDeck = const [],
    this.sessionIndex = 0,
    this.sessionAnswers = const {},
    this.isLoading = true,
    this.selectedCategory,
    this.mode = FlashcardSessionMode.all,
  });

  // Session Statistics
  int get sessionKnownCount =>
      sessionAnswers.values.where((v) => v == true).length;
  int get sessionUnknownCount =>
      sessionAnswers.values.where((v) => v == false).length;

  // Statistics
  int get totalCards => allCards.length;
  int get masteredCount => allCards.where((c) => c.status == FlashcardStatus.mastered).length;
  int get learningCount => allCards.where((c) => c.status == FlashcardStatus.learning).length;
  int get newCount => allCards.where((c) => c.status == FlashcardStatus.newCard).length;
  int get totalReviews => allCards.fold(0, (sum, c) => sum + c.reviewCount);

  // Category Filtered Statistics
  List<Flashcard> get filteredCards {
    if (selectedCategory == null) return allCards;
    if (selectedCategory == 'AI生成') {
      return allCards
          .where((c) => c.source == FlashcardSource.ai || c.category == 'AI生成')
          .toList();
    }
    return allCards.where((c) => c.category == selectedCategory).toList();
  }

  int get filteredTotalCount => filteredCards.length;
  int get filteredMasteredCount =>
      filteredCards.where((c) => c.status == FlashcardStatus.mastered).length;
  int get filteredLearningCount =>
      filteredCards.where((c) => c.status == FlashcardStatus.learning).length;
  int get filteredNewCount =>
      filteredCards.where((c) => c.status == FlashcardStatus.newCard).length;
  int get filteredUnlearnedCount =>
      filteredCards.where((c) => c.status != FlashcardStatus.mastered).length;

  double get filteredMasteredPercent =>
      filteredTotalCount > 0 ? filteredMasteredCount / filteredTotalCount : 0;
  double get filteredLearningPercent =>
      filteredTotalCount > 0 ? filteredLearningCount / filteredTotalCount : 0;
  double get filteredNewPercent =>
      filteredTotalCount > 0 ? filteredNewCount / filteredTotalCount : 0;

  double get masteredPercent => totalCards > 0 ? masteredCount / totalCards : 0;
  double get learningPercent => totalCards > 0 ? learningCount / totalCards : 0;
  double get newPercent => totalCards > 0 ? newCount / totalCards : 0;

  bool get isSessionComplete => sessionDeck.isNotEmpty && sessionIndex >= sessionDeck.length;
  Flashcard? get currentCard =>
      sessionIndex < sessionDeck.length ? sessionDeck[sessionIndex] : null;

  bool get canGoPrevious => sessionIndex > 0;
  bool get canGoNext => sessionIndex < sessionDeck.length - 1;

  List<String> get categories {
    final cats = allCards.map((c) => c.category).toSet().toList();
    if (allCards.any((c) => c.source == FlashcardSource.ai) && !cats.contains('AI生成')) {
      cats.add('AI生成');
    }
    cats.sort();
    return cats;
  }

  FlashcardState copyWith({
    List<Flashcard>? allCards,
    List<Flashcard>? sessionDeck,
    int? sessionIndex,
    Map<int, bool>? sessionAnswers,
    bool? isLoading,
    String? Function()? selectedCategory,
    FlashcardSessionMode? mode,
  }) {
    return FlashcardState(
      allCards: allCards ?? this.allCards,
      sessionDeck: sessionDeck ?? this.sessionDeck,
      sessionIndex: sessionIndex ?? this.sessionIndex,
      sessionAnswers: sessionAnswers ?? this.sessionAnswers,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory:
          selectedCategory != null ? selectedCategory() : this.selectedCategory,
      mode: mode ?? this.mode,
    );
  }
}

enum FlashcardSessionMode { all, unlearned }

// --- Provider ---

final flashcardControllerProvider =
    NotifierProvider<FlashcardController, FlashcardState>(() {
  return FlashcardController();
});

// --- Controller ---

class FlashcardController extends Notifier<FlashcardState> {
  final FlashcardRepository _repository = FlashcardRepository();

  @override
  FlashcardState build() {
    scheduleMicrotask(() => _loadCards());
    return const FlashcardState();
  }

  Future<void> _loadCards() async {
    // 0. Load deleted card IDs
    final deletedIds = await _repository.loadDeletedCardIds();

    // 1. Generate seed cards
    final seedCards = FlashcardSeedsData.generateFromDrillSeeds()
        .where((c) => !deletedIds.contains(c.id))
        .toList();

    // 2. Load user/AI cards from Hive
    final userCards = (await _repository.loadUserCards())
        .where((c) => !deletedIds.contains(c.id))
        .toList();

    // 3. Load review states
    final reviewStates = await _repository.loadReviewStates();

    // 4. Merge: apply saved review state to seed cards
    final allCards = <Flashcard>[];
    for (final card in seedCards) {
      if (reviewStates.containsKey(card.id)) {
        final saved = reviewStates[card.id]!;
        allCards.add(card.copyWith(
          reviewCount: saved.reviewCount,
          correctCount: saved.correctCount,
          lastReviewedAt: saved.lastReviewedAt,
          status: saved.status,
        ));
      } else {
        allCards.add(card);
      }
    }

    // 5. Add user/AI cards (already have state embedded)
    for (final card in userCards) {
      if (reviewStates.containsKey(card.id)) {
        final saved = reviewStates[card.id]!;
        allCards.add(card.copyWith(
          reviewCount: saved.reviewCount,
          correctCount: saved.correctCount,
          lastReviewedAt: saved.lastReviewedAt,
          status: saved.status,
        ));
      } else {
        allCards.add(card);
      }
    }

    state = state.copyWith(allCards: allCards, isLoading: false);
  }

  /// Set category filter
  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: () => category);
  }

  /// Start a flashcard session
  void startSession(FlashcardSessionMode mode) {
    List<Flashcard> deck;

    switch (mode) {
      case FlashcardSessionMode.all:
        deck = _filteredCards();
        break;
      case FlashcardSessionMode.unlearned:
        deck = _filteredCards()
            .where((c) => c.status != FlashcardStatus.mastered)
            .toList();
        break;
    }

    deck.shuffle();

    state = state.copyWith(
      sessionDeck: deck,
      sessionIndex: 0,
      sessionAnswers: {},
      mode: mode,
    );
  }

  List<Flashcard> _filteredCards() {
    if (state.selectedCategory == null) {
      return List<Flashcard>.from(state.allCards);
    }
    if (state.selectedCategory == 'AI生成') {
      return state.allCards
          .where((c) => c.source == FlashcardSource.ai || c.category == 'AI生成')
          .toList();
    }
    return state.allCards
        .where((c) => c.category == state.selectedCategory)
        .toList();
  }

  /// Change active session index (e.g., when swiping cards)
  void setSessionIndex(int index) {
    if (index >= 0 && index <= state.sessionDeck.length) {
      state = state.copyWith(sessionIndex: index);
    }
  }

  /// Answer card at specific index
  Future<void> answerCard({required int index, required bool known}) async {
    if (index < 0 || index >= state.sessionDeck.length) return;

    final card = state.sessionDeck[index];
    if (known) {
      card.markKnown();
    } else {
      card.markUnknown();
    }

    // Update in allCards
    final updatedAll = state.allCards.map((c) {
      if (c.id == card.id) return card;
      return c;
    }).toList();

    await _repository.saveReviewState(card);

    final updatedAnswers = Map<int, bool>.from(state.sessionAnswers);
    updatedAnswers[index] = known;

    state = state.copyWith(
      allCards: updatedAll,
      sessionAnswers: updatedAnswers,
    );
  }

  /// Mark current card as known and advance
  Future<void> markCurrentKnown() async {
    await answerCard(index: state.sessionIndex, known: true);
  }

  /// Mark current card as unknown and advance
  Future<void> markCurrentUnknown() async {
    await answerCard(index: state.sessionIndex, known: false);
  }

  /// Retry only unknown cards from last session
  void retryUnknownCards() {
    final unknownCards = state.sessionDeck
        .where((c) => c.status != FlashcardStatus.mastered)
        .toList()
      ..shuffle();

    state = state.copyWith(
      sessionDeck: unknownCards,
      sessionIndex: 0,
      sessionAnswers: {},
    );
  }

  /// Add a user-created card
  Future<void> addUserCard({
    required String term,
    required String meaning,
    required String example,
    required String exampleTranslation,
    required String category,
    String hint = '',
  }) async {
    final card = Flashcard(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      term: term,
      hint: hint,
      meaning: meaning,
      example: example,
      exampleTranslation: exampleTranslation,
      category: category,
      source: FlashcardSource.user,
    );

    await _repository.saveCard(card);

    state = state.copyWith(allCards: [...state.allCards, card]);
  }

  /// Delete a card by ID
  Future<void> deleteUserCard(String id) async {
    await deleteUserCards([id]);
  }

  /// Bulk delete cards by IDs
  Future<void> deleteUserCards(List<String> ids) async {
    await _repository.deleteCards(ids);
    final idSet = ids.toSet();
    state = state.copyWith(
      allCards: state.allCards.where((c) => !idSet.contains(c.id)).toList(),
    );
  }

  /// Update status of a specific card directly
  Future<void> updateCardStatus(String cardId, FlashcardStatus status) async {
    final index = state.allCards.indexWhere((c) => c.id == cardId);
    if (index == -1) return;

    final updatedCard = state.allCards[index].copyWith(status: status);
    await _repository.saveReviewState(updatedCard);

    final updatedAll = List<Flashcard>.from(state.allCards);
    updatedAll[index] = updatedCard;

    state = state.copyWith(allCards: updatedAll);
  }

  /// Reload cards from storage
  Future<void> reload() async {
    state = state.copyWith(isLoading: true);
    await _loadCards();
  }

  /// Clear all user cards and review history, then reload seed cards
  Future<void> clearAll() async {
    state = state.copyWith(isLoading: true);
    await _repository.clearAll();
    await _loadCards();
  }
}

