class DrillQuestion {
  final String category;
  final String topic;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? translation;

  const DrillQuestion({
    required this.category,
    required this.topic,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.translation,
  });

  /// Returns a new DrillQuestion with options shuffled and correctIndex updated
  DrillQuestion shuffled() {
    final correctOption = options[correctIndex];
    final shuffledOptions = List<String>.from(options)..shuffle();
    final newCorrectIndex = shuffledOptions.indexOf(correctOption);
    return DrillQuestion(
      category: category,
      topic: topic,
      question: question,
      options: shuffledOptions,
      correctIndex: newCorrectIndex,
      explanation: explanation,
      translation: translation,
    );
  }
}
