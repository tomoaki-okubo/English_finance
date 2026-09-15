import 'dart:convert';

enum FlashcardSource { seed, user, ai }
enum FlashcardStatus { newCard, learning, mastered }

class Flashcard {
  final String id;
  final String term;
  final String hint;
  final String meaning;
  final String example;
  final String exampleTranslation;
  final String category;
  final FlashcardSource source;
  int reviewCount;
  int correctCount;
  DateTime? lastReviewedAt;
  FlashcardStatus status;

  Flashcard({
    required this.id,
    required this.term,
    required this.hint,
    required this.meaning,
    required this.example,
    required this.exampleTranslation,
    required this.category,
    required this.source,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.lastReviewedAt,
    this.status = FlashcardStatus.newCard,
  });

  /// Mark as "known" — 3 consecutive correct → mastered
  void markKnown() {
    reviewCount++;
    correctCount++;
    lastReviewedAt = DateTime.now();
    if (correctCount >= 3) {
      status = FlashcardStatus.mastered;
    } else {
      status = FlashcardStatus.learning;
    }
  }

  /// Mark as "still learning" — resets consecutive correct count
  void markUnknown() {
    reviewCount++;
    correctCount = 0;
    lastReviewedAt = DateTime.now();
    status = FlashcardStatus.learning;
  }

  Flashcard copyWith({
    String? id,
    String? term,
    String? hint,
    String? meaning,
    String? example,
    String? exampleTranslation,
    String? category,
    FlashcardSource? source,
    int? reviewCount,
    int? correctCount,
    DateTime? lastReviewedAt,
    FlashcardStatus? status,
  }) {
    return Flashcard(
      id: id ?? this.id,
      term: term ?? this.term,
      hint: hint ?? this.hint,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      category: category ?? this.category,
      source: source ?? this.source,
      reviewCount: reviewCount ?? this.reviewCount,
      correctCount: correctCount ?? this.correctCount,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      status: status ?? this.status,
    );
  }

  /// Serialize to JSON string for Hive storage
  String toJson() {
    return jsonEncode({
      'id': id,
      'term': term,
      'hint': hint,
      'meaning': meaning,
      'example': example,
      'exampleTranslation': exampleTranslation,
      'category': category,
      'source': source.index,
      'reviewCount': reviewCount,
      'correctCount': correctCount,
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'status': status.index,
    });
  }

  /// Deserialize from JSON string
  factory Flashcard.fromJson(String jsonStr) {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    return Flashcard(
      id: data['id'] as String,
      term: data['term'] as String,
      hint: data['hint'] as String? ?? '',
      meaning: data['meaning'] as String,
      example: data['example'] as String? ?? '',
      exampleTranslation: data['exampleTranslation'] as String? ?? '',
      category: data['category'] as String? ?? 'General',
      source: FlashcardSource.values[data['source'] as int? ?? 0],
      reviewCount: data['reviewCount'] as int? ?? 0,
      correctCount: data['correctCount'] as int? ?? 0,
      lastReviewedAt: data['lastReviewedAt'] != null
          ? DateTime.tryParse(data['lastReviewedAt'] as String)
          : null,
      status: FlashcardStatus.values[data['status'] as int? ?? 0],
    );
  }
}
