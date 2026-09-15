import 'dart:convert';
import 'drill_question.dart';

class SavedDrillItem {
  final String id;
  final String category;
  final String topic;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? userAnswer;
  final bool isMistake;
  final bool isBookmarked;
  final DateTime savedAt;
  final String? translation;

  const SavedDrillItem({
    required this.id,
    required this.category,
    required this.topic,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.userAnswer,
    this.isMistake = false,
    this.isBookmarked = false,
    required this.savedAt,
    this.translation,
  });

  SavedDrillItem copyWith({
    String? id,
    String? category,
    String? topic,
    String? question,
    List<String>? options,
    int? correctIndex,
    String? explanation,
    String? userAnswer,
    bool? isMistake,
    bool? isBookmarked,
    DateTime? savedAt,
    String? translation,
  }) {
    return SavedDrillItem(
      id: id ?? this.id,
      category: category ?? this.category,
      topic: topic ?? this.topic,
      question: question ?? this.question,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
      userAnswer: userAnswer ?? this.userAnswer,
      isMistake: isMistake ?? this.isMistake,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      savedAt: savedAt ?? this.savedAt,
      translation: translation ?? this.translation,
    );
  }

  DrillQuestion toDrillQuestion() {
    return DrillQuestion(
      category: category,
      topic: topic,
      question: question,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
      translation: translation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'topic': topic,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
      'userAnswer': userAnswer,
      'isMistake': isMistake,
      'isBookmarked': isBookmarked,
      'savedAt': savedAt.toIso8601String(),
      'translation': translation,
    };
  }

  factory SavedDrillItem.fromMap(Map<dynamic, dynamic> map) {
    return SavedDrillItem(
      id: map['id']?.toString() ?? '',
      category: map['category']?.toString() ?? 'IT General',
      topic: map['topic']?.toString() ?? 'General',
      question: map['question']?.toString() ?? '',
      options: (map['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      correctIndex: int.tryParse(map['correctIndex']?.toString() ?? '0') ?? 0,
      explanation: map['explanation']?.toString() ?? '',
      userAnswer: map['userAnswer']?.toString(),
      isMistake: map['isMistake'] == true,
      isBookmarked: map['isBookmarked'] == true,
      savedAt: DateTime.tryParse(map['savedAt']?.toString() ?? '') ?? DateTime.now(),
      translation: map['translation']?.toString(),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory SavedDrillItem.fromJson(String source) => SavedDrillItem.fromMap(jsonDecode(source));
}
