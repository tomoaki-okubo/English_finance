import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../correction/presentation/widgets/correction_modal.dart';
import '../../../llm_engine/domain/providers.dart';
import '../../../llm_engine/domain/entities/llm_config.dart';
import '../../domain/entities/drill_seed.dart';
import '../../domain/entities/drill_question.dart';
import '../../data/sources/drill_seeds_data.dart';
import '../controllers/saved_drills_controller.dart';
import '../../../llm_engine/data/services/model_downloader_service.dart';
import '../../../dashboard/presentation/controllers/training_activity_controller.dart';
import '../../../../core/services/ad_service.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  int _selectedOptionIndex = -1;
  bool _isAnswerRevealed = false;
  bool _isGenerating = false;
  int _questionCount = 0;
  int _correctAnswersCount = 0;

  late DrillQuestion _currentDrill;
  String? _currentTranslation;
  bool _isTranslationLoading = false;

  bool _isQuizStarted = false;
  bool _isQuizFinished = false;
  int _totalQuestionsLimit = 5; // 5, 10, 20, -1 (無限)

  // Track recently used seed indices to guarantee fresh questions without repetition
  final List<int> _recentSeedIndices = [];
  final List<DrillSeed> _allSeeds = DrillSeedsData.allSeeds;

  @override
  void initState() {
    super.initState();
    final firstSeed = _allSeeds[0];
    _currentDrill = _buildDrillFromSeed(firstSeed);
    _currentTranslation = firstSeed.sentenceTranslation;
    _recentSeedIndices.add(0);
  }

  void _startQuiz(int limit) {
    setState(() {
      _totalQuestionsLimit = limit;
      _questionCount = 0;
      _correctAnswersCount = 0;
      _isQuizStarted = true;
      _isQuizFinished = false;
    });
    _generateNextQuestion();
  }

  DrillSeed _pickNextUniqueSeed() {
    final availableIndices = <int>[];
    for (int i = 0; i < _allSeeds.length; i++) {
      if (!_recentSeedIndices.contains(i)) {
        availableIndices.add(i);
      }
    }

    final random = Random();
    int chosenIndex;
    if (availableIndices.isNotEmpty) {
      chosenIndex = availableIndices[random.nextInt(availableIndices.length)];
    } else {
      _recentSeedIndices.removeRange(0, _recentSeedIndices.length ~/ 2);
      chosenIndex = random.nextInt(_allSeeds.length);
    }

    _recentSeedIndices.add(chosenIndex);
    if (_recentSeedIndices.length > 25) {
      _recentSeedIndices.removeAt(0);
    }

    return _allSeeds[chosenIndex];
  }

  DrillQuestion _buildDrillFromSeed(DrillSeed seed, [String? customSentence, String? customTranslation]) {
    String sentence = customSentence ?? seed.defaultSentence;
    String translation = customTranslation ?? seed.sentenceTranslation;

    if (!sentence.contains('_____')) {
      final regex = RegExp(RegExp.escape(seed.targetTerm), caseSensitive: false);
      if (regex.hasMatch(sentence)) {
        sentence = sentence.replaceFirst(regex, '_____');
      } else {
        sentence = seed.defaultSentence;
        translation = seed.sentenceTranslation;
      }
    }

    final options = [seed.targetTerm, ...seed.distractors];
    return DrillQuestion(
      category: seed.category,
      topic: seed.topic,
      question: sentence,
      options: options,
      correctIndex: 0,
      explanation: seed.explanation,
      translation: translation,
    ).shuffled();
  }

  Future<void> _generateNextQuestion() async {
    setState(() {
      _isGenerating = true;
      _selectedOptionIndex = -1;
      _isAnswerRevealed = false;
      _currentTranslation = null;
      _isTranslationLoading = false;
    });

    final seed = _pickNextUniqueSeed();

    try {
      final modelState = ref.read(modelDownloaderProvider);
      final modelPath = modelState.filePath ?? await ref.read(modelDownloaderProvider.notifier).getModelFilePath();
      final repository = ref.read(llmEngineRepositoryProvider);
      await repository.initialize(LlmConfig(modelPath: modelPath));

      // Step 1: Generate English question ONLY (no translation - let the model focus on one task)
      const systemPrompt = 'You are a Finance English quiz writer. Output JSON only. '
          'Format: {"question": "..."}';
      
      final userText = 'Write 1 professional English sentence about ${seed.category} (${seed.topic}). '
          'The sentence must use the word "${seed.targetTerm}" (${seed.hint}) but replace "${seed.targetTerm}" with "_____". '
          'Return JSON: {"question": "..."}';

      final response = await repository.evaluateCorrection(
        userText: userText,
        systemPrompt: systemPrompt,
      );

      final jsonStr = _extractFirstJson(response);
      if (jsonStr != null) {
        final data = jsonDecode(jsonStr);
        String generatedQuestion = data['question']?.toString().trim() ?? '';
        generatedQuestion = generatedQuestion.replaceAll('"', '').trim();

        // Safeguard: If the generated question is empty, contains Japanese, or lacks blank
        final questionHasJapanese = RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]').hasMatch(generatedQuestion);
        final hasBlank = generatedQuestion.contains('___');
        if (generatedQuestion.isEmpty || questionHasJapanese || !hasBlank) {
          final drill = _buildDrillFromSeed(seed);
          if (!mounted) return;
          setState(() {
            _currentDrill = drill;
            _currentTranslation = drill.translation;
            _isTranslationLoading = false;
            _questionCount++;
            _isGenerating = false;
          });
          return;
        }

        if (generatedQuestion.isNotEmpty &&
            generatedQuestion.length >= 15 &&
            !generatedQuestion.toLowerCase().contains('sentence with') &&
            !generatedQuestion.toLowerCase().contains('the production server crashed')) {
          
          print('[ExerciseScreen] Successfully applied AI generated drill: $generatedQuestion');
          final drill = _buildDrillFromSeed(seed, generatedQuestion, '');
          if (!mounted) return;
          setState(() {
            _currentDrill = drill;
            _questionCount++;
            _isGenerating = false;
          });

          // Step 2: Always trigger dedicated translation with few-shot prompt
          final japaneseTerm = _extractJapaneseTerm(seed);
          _triggerTranslationRetry(generatedQuestion, seed.targetTerm, japaneseTerm);
          return;
        }
      }
    } catch (e) {
      print('[ExerciseScreen] Local LLM not ready or model missing. Using built-in finance seed drill.');
    }

    // Default Fallback
    final fallbackDrill = _buildDrillFromSeed(seed);
    if (!mounted) return;
    setState(() {
      _currentDrill = fallbackDrill;
      _currentTranslation = fallbackDrill.translation;
      _isTranslationLoading = false;
      _questionCount++;
      _isGenerating = false;
    });
  }

  String _extractJapaneseTerm(DrillSeed seed) {
    final match = RegExp(r'[（(]([\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF/ー]+)[）)]').firstMatch(seed.explanation);
    if (match != null && match.group(1) != null) {
      return match.group(1)!;
    }
    const dict = {
      'turnover': '回転率',
      'hostile': '敵対的',
      'forecast': '業績予想',
      'liquidate': '清算',
      'benchmark': 'ベンチマーク',
      'reserve': '準備金',
      'guarantee': '保証',
      'buffer': 'バッファー',
      'escrow': 'エスクロー',
      'collateral': '担保',
      'covenant': '財務誓約条項',
      'syndicated': '協調融資（シンジケート）',
      'amortization': '減価償却',
      'liquidity': '流動性',
      'solvency': '支払能力',
      'leverage': 'レバレッジ',
      'maturity': '満期',
      'derivative': 'デリバティブ',
      'hedging': 'ヘッジ',
      'valuation': '企業価値評価',
      'default': 'デフォルト',
      'yield': '利回り',
      'spread': 'スプレッド',
      'equity': '自己資本',
      'liability': '負債',
      'impairment': '減損',
      'arbitrage': '裁定取引',
      'dividend': '配当',
    };
    return dict[seed.targetTerm.toLowerCase()] ?? seed.targetTerm;
  }

  Future<void> _triggerTranslationRetry(String questionWithBlank, String targetTerm, String japaneseTerm) async {
    setState(() {
      _isTranslationLoading = true;
      _currentTranslation = null;
    });

    try {
      final modelState = ref.read(modelDownloaderProvider);
      final modelPath = modelState.filePath ?? await ref.read(modelDownloaderProvider.notifier).getModelFilePath();
      final repository = ref.read(llmEngineRepositoryProvider);
      await repository.initialize(LlmConfig(modelPath: modelPath));

      final fullSentence = questionWithBlank.replaceAll('_____', targetTerm);
      
      const systemPrompt = 'あなたはプロの金融翻訳家です。英文を正確な日本語に和訳してください。'
          '対象の金融専門用語（target term）とその日本語訳・意味を省略せず、必ず自然な日本語訳の中に反映させてください。日本語のみ出力。';
      
      final userText = 'Target Term: "$targetTerm" ($japaneseTerm)\n'
          'Sentence: $fullSentence →';

      final response = await repository.evaluateCorrection(
        userText: userText,
        systemPrompt: systemPrompt,
      );

      // Clean up: remove quotes, arrows, and any English prefix the model may have echoed
      String cleanResponse = response.replaceAll('"', '').replaceAll('→', '').trim();
      // If model echoed the English sentence before the translation, take the last part
      if (cleanResponse.contains('\n')) {
        final lines = cleanResponse.split('\n');
        // Find the last line that contains Japanese
        for (int i = lines.length - 1; i >= 0; i--) {
          if (RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]').hasMatch(lines[i])) {
            cleanResponse = lines[i].trim();
            break;
          }
        }
      }
      
      final hasJapanese = RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]').hasMatch(cleanResponse);

      if (!mounted) return;
      if (cleanResponse.isNotEmpty && hasJapanese && cleanResponse.length >= 5) {
        setState(() {
          _currentTranslation = cleanResponse;
          _isTranslationLoading = false;
          _currentDrill = DrillQuestion(
            category: _currentDrill.category,
            topic: _currentDrill.topic,
            question: _currentDrill.question,
            options: _currentDrill.options,
            correctIndex: _currentDrill.correctIndex,
            explanation: _currentDrill.explanation,
            translation: cleanResponse,
          );
        });
      } else {
        // Translation failed. Hide translation section.
        setState(() {
          _currentTranslation = null;
          _isTranslationLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentTranslation = null;
        _isTranslationLoading = false;
      });
    }
  }

  String? _extractFirstJson(String text) {
    final start = text.indexOf('{');
    if (start < 0) return null;
    int depth = 0;
    bool inString = false;
    bool escaped = false;
    for (int i = start; i < text.length; i++) {
      final ch = text[i];
      if (escaped) {
        escaped = false;
        continue;
      }
      if (ch == '\\' && inString) {
        escaped = true;
        continue;
      }
      if (ch == '"') {
        inString = !inString;
        continue;
      }
      if (!inString) {
        if (ch == '{') depth++;
        if (ch == '}') {
          depth--;
          if (depth == 0) return text.substring(start, i + 1);
        }
      }
    }
    return null;
  }

  void _handleNextQuestion() {
    if (_totalQuestionsLimit != -1 && _questionCount >= _totalQuestionsLimit) {
      AdService.instance.showInterstitialAd(
        onAdDismissed: () {
          if (mounted) {
            setState(() {
              _isQuizFinished = true;
            });
          }
        },
      );
    } else {
      _generateNextQuestion();
    }
  }

  void _showCorrectionModal() {
    final selectedIdx = _selectedOptionIndex;
    final String userAnswer = (selectedIdx >= 0 && selectedIdx < _currentDrill.options.length)
        ? _currentDrill.options[selectedIdx]
        : '';
    final bool isCorrect = selectedIdx == _currentDrill.correctIndex;
    final savedController = ref.read(savedDrillsControllerProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final currentBookmarked = ref.watch(savedDrillsControllerProvider).items.any(
                (e) => e.question == _currentDrill.question && e.isBookmarked,
              );

          return CorrectionModal(
            userAnswer: userAnswer,
            correctAnswer: _currentDrill.options[_currentDrill.correctIndex],
            isCorrect: isCorrect,
            customExplanation: _currentDrill.explanation,
            question: _currentDrill.question.replaceAll('_____', _currentDrill.options[_currentDrill.correctIndex]),
            translation: _currentTranslation,
            isTranslationLoading: _isTranslationLoading,
            isBookmarked: currentBookmarked,
            onToggleBookmark: () async {
              await savedController.toggleBookmark(_currentDrill);
              setModalState(() {});
              setState(() {});
            },
            onNextQuestion: () {
              Navigator.of(context).pop();
              _handleNextQuestion();
            },
          );
        },
      ),
    );
  }

  void _submitAnswer() {
    if (_selectedOptionIndex == -1 || _isAnswerRevealed) return;

    setState(() {
      _isAnswerRevealed = true;
    });

    final isCorrect = _selectedOptionIndex == _currentDrill.correctIndex;
    final savedController = ref.read(savedDrillsControllerProvider.notifier);

    if (isCorrect) {
      _correctAnswersCount++;
    }

    // Record training activity on dashboard calendar
    ref.read(trainingActivityControllerProvider.notifier).recordActivity(drills: 1);

    // If incorrect, automatically record into mistakes notebook
    if (!isCorrect) {
      savedController.saveMistake(
        drill: _currentDrill,
        userAnswer: _currentDrill.options[_selectedOptionIndex],
      );
    }

    _showCorrectionModal();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isQuizStarted) {
      return _buildSetupScreen(theme);
    }

    if (_isQuizFinished) {
      return _buildFinishScreen(theme);
    }

    final downloadState = ref.watch(modelDownloaderProvider);
    final savedDrillsState = ref.watch(savedDrillsControllerProvider);
    final savedController = ref.read(savedDrillsControllerProvider.notifier);

    // If model not ready, display download card with live progress
    Widget modelDownloadCard = _buildModelDownloadCard(downloadState, theme);
    final isBookmarked = savedDrillsState.items.any(
      (e) => e.question == _currentDrill.question && e.isBookmarked,
    );

    // Progress Bar UI
    double? progressPercent = _totalQuestionsLimit != -1 
        ? (_questionCount / _totalQuestionsLimit).clamp(0.0, 1.0)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_totalQuestionsLimit == -1 
            ? 'Drills (Q$_questionCount)' 
            : 'Drills ($_questionCount/$_totalQuestionsLimit)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AdService.instance.showInterstitialAd(
              onAdDismissed: () {
                if (mounted) {
                  setState(() {
                    _isQuizStarted = false;
                  });
                }
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: savedDrillsState.items.isNotEmpty,
              label: Text('${savedDrillsState.items.length}'),
              child: const Icon(Icons.bookmarks_outlined),
            ),
            tooltip: '復習・見返しノート',
            onPressed: () {
              context.push('/saved-drills');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (progressPercent != null) ...[
              LinearProgressIndicator(
                value: progressPercent,
                minHeight: 5,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ],
            Expanded(
              child: _isGenerating
                  ? _buildGeneratingState(theme)
                  : Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          modelDownloadCard,
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.category_rounded, size: 13, color: theme.colorScheme.primary),
                                                  const Gap(4),
                                                  Text(
                                                    _currentDrill.category,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: theme.colorScheme.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.auto_awesome, size: 13, color: theme.colorScheme.secondary),
                                                  const Gap(4),
                                                  Text(
                                                    _currentDrill.topic,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: theme.colorScheme.secondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                          color: isBookmarked ? theme.colorScheme.primary : Colors.grey,
                                        ),
                                        tooltip: isBookmarked ? 'ブックマーク解除' : '復習ノートに保存',
                                        onPressed: () async {
                                          final res = await savedController.toggleBookmark(_currentDrill);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(res ? '復習ノートに保存しました' : 'ブックマークを解除しました'),
                                                duration: const Duration(seconds: 1),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const Gap(16),
                                  Text(
                                    _currentDrill.question,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.5),
                                  ),
                                  const Gap(32),
                                  ...List.generate(_currentDrill.options.length, (index) {
                                    final isSelected = _selectedOptionIndex == index;
                                    final isCorrect = index == _currentDrill.correctIndex;
                                    
                                    Color cardColor = theme.cardTheme.color ?? theme.cardColor;
                                    Color borderColor = theme.dividerColor.withValues(alpha: 0.1);
                                    
                                    if (_isAnswerRevealed) {
                                        if (isCorrect) {
                                          cardColor = Colors.green.withValues(alpha: 0.1);
                                          borderColor = Colors.green;
                                        } else if (isSelected) {
                                          cardColor = Colors.red.withValues(alpha: 0.1);
                                          borderColor = Colors.red;
                                        }
                                    } else if (isSelected) {
                                      cardColor = theme.colorScheme.primary.withValues(alpha: 0.1);
                                      borderColor = theme.colorScheme.primary;
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: InkWell(
                                        onTap: _isAnswerRevealed ? null : () {
                                          setState(() {
                                            _selectedOptionIndex = index;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: cardColor,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: borderColor, width: isSelected || (_isAnswerRevealed && isCorrect) ? 2 : 1),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 32,
                                                height: 32,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: borderColor),
                                                ),
                                                child: Text(
                                                  String.fromCharCode(65 + index),
                                                  style: TextStyle(fontWeight: FontWeight.bold, color: _isAnswerRevealed && isCorrect ? Colors.green : null),
                                                ),
                                              ),
                                              const Gap(16),
                                              Expanded(
                                                child: Text(
                                                  _currentDrill.options[index],
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              if (_isAnswerRevealed && isCorrect)
                                                const Icon(Icons.check_circle, color: Colors.green),
                                              if (_isAnswerRevealed && isSelected && !isCorrect)
                                                const Icon(Icons.cancel, color: Colors.red),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const Gap(16),
                          Row(
                            children: [
                              if (_isAnswerRevealed) ...[
                                OutlinedButton.icon(
                                  onPressed: _showCorrectionModal,
                                  icon: const Icon(Icons.menu_book_rounded),
                                  label: const Text('解説を表示', style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _handleNextQuestion,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: theme.colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: Text(
                                      _totalQuestionsLimit != -1 && _questionCount >= _totalQuestionsLimit
                                          ? '結果を見る'
                                          : 'Next AI Question',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _selectedOptionIndex == -1 ? null : _submitAnswer,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: theme.colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: const Text('Submit Answer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupScreen(ThemeData theme) {
    final downloadState = ref.watch(modelDownloaderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('金融英語ドリル'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon Header
                      Column(
                        children: [
                          const Gap(16),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.school_outlined,
                                size: 64,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const Gap(24),
                          const Center(
                            child: Text(
                              '金融英語ドリル',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Gap(8),
                          Center(
                            child: Text(
                              'AIがリアルタイムに現場に即した金融英語問題を生成します。\nあなたの設定した問題数を解いて学習しましょう。',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                            ),
                          ),
                          const Gap(20),
                          _buildModelDownloadCard(downloadState, theme),
                        ],
                      ),
                      // Options section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Gap(24),
                          const Text(
                            '問題数を選択してください',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const Gap(12),
                          // Option Row
                          Row(
                            children: [
                              _buildLimitChip(5),
                              const Gap(10),
                              _buildLimitChip(10),
                              const Gap(10),
                              _buildLimitChip(20),
                              const Gap(10),
                              _buildLimitChip(-1, label: '無限'),
                            ],
                          ),
                        ],
                      ),
                      // Start button
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: ElevatedButton(
                          onPressed: () => _startQuiz(_totalQuestionsLimit),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            'トレーニングを開始する',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLimitChip(int limit, {String? label}) {
    final isSelected = _totalQuestionsLimit == limit;
    final theme = Theme.of(context);
    final text = label ?? '$limit問';

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _totalQuestionsLimit = limit;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : theme.cardTheme.color ?? theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishScreen(ThemeData theme) {
    final double correctRate = _questionCount > 0 
        ? (_correctAnswersCount / _questionCount) * 100 
        : 0;

    String ratingMessage = 'Keep practicing!';
    String description = '少しずつ表現を身につけていきましょう！';
    IconData feedbackIcon = Icons.stars_outlined;
    Color scoreColor = theme.colorScheme.primary;

    if (correctRate >= 90) {
      ratingMessage = 'Perfect!';
      description = '素晴らしい！IT英語の実戦表現が完璧に身についています。';
      feedbackIcon = Icons.emoji_events_outlined;
      scoreColor = Colors.orange;
    } else if (correctRate >= 70) {
      ratingMessage = 'Great Job!';
      description = '非常に良い成績です！この調子で学習を継続しましょう。';
      feedbackIcon = Icons.thumb_up_alt_outlined;
      scoreColor = Colors.green;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Trophy/Feedback Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    feedbackIcon,
                    size: 64,
                    color: scoreColor,
                  ),
                ),
              ),
              const Gap(24),
              Center(
                child: Text(
                  ratingMessage,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: scoreColor),
                ),
              ),
              const Gap(8),
              Center(
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              // Result Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('解答数', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const Gap(4),
                          Text('$_questionCount問', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(width: 1, height: 40, color: theme.dividerColor.withValues(alpha: 0.2)),
                      Column(
                        children: [
                          const Text('正解数', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const Gap(4),
                          Text('$_correctAnswersCount問', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      Container(width: 1, height: 40, color: theme.dividerColor.withValues(alpha: 0.2)),
                      Column(
                        children: [
                          const Text('正解率', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const Gap(4),
                          Text('${correctRate.toStringAsFixed(0)}%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: scoreColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isQuizStarted = false;
                    _isQuizFinished = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('もう一度挑戦する', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const Gap(12),
              OutlinedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('ダッシュボードに戻る', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, size: 40, color: theme.colorScheme.primary),
          ),
          const Gap(24),
          const CircularProgressIndicator(),
          const Gap(20),
          const Text(
            'Generating new Finance English drill with AI...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          Text(
            'Creating real-world Finance & Banking scenario & choices',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildModelDownloadCard(ModelDownloadState downloadState, ThemeData theme) {
    if (downloadState.status == ModelDownloadStatus.ready) {
      return const SizedBox.shrink();
    }

    final isDownloading = downloadState.status == ModelDownloadStatus.downloading;
    final percentText = (downloadState.progress * 100).toStringAsFixed(1);
    final downloadedMB = (downloadState.downloadedBytes / (1024 * 1024)).toStringAsFixed(1);
    final totalMB = (downloadState.totalBytes / (1024 * 1024)).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_outlined, color: theme.colorScheme.primary, size: 24),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDownloading ? 'AI Model をダウンロード中 ($percentText%)' : 'On-Device AI Model (~398MB)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const Gap(2),
                    Text(
                      isDownloading
                          ? '$downloadedMB MB / $totalMB MB'
                          : 'ローカルAIで問題を即時生成するにはモデルが必要です',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              if (!isDownloading) ...[
                const Gap(8),
                ElevatedButton(
                  onPressed: () {
                    ref.read(modelDownloaderProvider.notifier).startDownload();
                  },
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text('Download', style: TextStyle(fontSize: 12)),
                ),
              ],
            ],
          ),
          if (isDownloading) ...[
            const Gap(10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: downloadState.progress > 0 ? downloadState.progress : null,
                minHeight: 6,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
