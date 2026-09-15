class DrillSeed {
  final String category;
  final String topic;
  final String targetTerm;
  final List<String> distractors;
  final String hint;
  final String defaultSentence;
  final String explanation;
  final String sentenceTranslation;

  const DrillSeed({
    required this.category,
    required this.topic,
    required this.targetTerm,
    required this.distractors,
    required this.hint,
    required this.defaultSentence,
    required this.explanation,
    required this.sentenceTranslation,
  });
}
