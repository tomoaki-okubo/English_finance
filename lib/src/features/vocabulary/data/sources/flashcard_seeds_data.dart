import '../../../exercises/data/sources/drill_seeds_data.dart';
import '../../domain/entities/flashcard.dart';

/// Converts existing DrillSeedsData into Flashcard entities.
class FlashcardSeedsData {
  static List<Flashcard> generateFromDrillSeeds() {
    return DrillSeedsData.allSeeds.asMap().entries.map((entry) {
      final index = entry.key;
      final seed = entry.value;
      return Flashcard(
        id: 'seed_$index',
        term: seed.targetTerm,
        hint: seed.hint,
        meaning: seed.explanation,
        example: seed.defaultSentence.replaceAll('_____', seed.targetTerm),
        exampleTranslation: seed.sentenceTranslation,
        category: seed.category,
        source: FlashcardSource.seed,
      );
    }).toList();
  }

  /// Get all unique categories from DrillSeedsData
  static List<String> get allCategories {
    final categories = DrillSeedsData.allSeeds
        .map((s) => s.category)
        .toSet()
        .toList()
      ..sort();
    return categories;
  }
}
