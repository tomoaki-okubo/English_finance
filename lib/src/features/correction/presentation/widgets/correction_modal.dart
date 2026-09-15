import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CorrectionModal extends StatelessWidget {
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String? customExplanation;
  final VoidCallback? onNextQuestion;
  final bool isBookmarked;
  final VoidCallback? onToggleBookmark;
  final String? question;
  final String? translation;
  final bool isTranslationLoading;

  const CorrectionModal({
    super.key,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.customExplanation,
    this.onNextQuestion,
    this.isBookmarked = false,
    this.onToggleBookmark,
    this.question,
    this.translation,
    this.isTranslationLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      padding: const EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.lightbulb_outline,
                color: isCorrect ? Colors.green : theme.colorScheme.secondary,
                size: 32,
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  isCorrect ? 'Excellent!' : 'Good try, but here is a better way',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              if (onToggleBookmark != null)
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? theme.colorScheme.primary : Colors.grey,
                  ),
                  tooltip: isBookmarked ? 'ブックマーク解除' : '復習ノートに保存',
                  onPressed: onToggleBookmark,
                ),
            ],
          ),
          if (!isCorrect) ...[
            const Gap(12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_stories_outlined, size: 16, color: Colors.orange),
                  Gap(8),
                  Expanded(
                    child: Text(
                      '間違えた問題は「復習ノート」に自動保存されました',
                      style: TextStyle(fontSize: 12, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Flexible(
            child: SingleChildScrollView(
              child: _buildFeedbackItem(
                context,
                category: 'Finance / Business Terminology',
                issueText: userAnswer,
                suggestion: correctAnswer,
                explanationJa: customExplanation ??
                    '金融実務における最適な専門用語表現をご確認ください。',
                isCorrect: isCorrect,
                question: question,
                translation: translation,
                isTranslationLoading: isTranslationLoading,
              ),
            ),
          ),
          const Gap(24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onNextQuestion != null) {
                onNextQuestion!();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Next AI Question (次の問題へ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackItem(
    BuildContext context, {
    required String category,
    required String issueText,
    required String suggestion,
    required String explanationJa,
    required bool isCorrect,
    String? question,
    String? translation,
    required bool isTranslationLoading,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              category,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.secondary),
            ),
          ),
          const Gap(12),
          if (!isCorrect) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.close, color: Colors.red, size: 20),
                const Gap(8),
                Expanded(
                  child: Text(
                    issueText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check, color: Colors.green, size: 20),
              const Gap(8),
              Expanded(
                child: Text(
                  suggestion,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (question != null && question.isNotEmpty) ...[
            const Gap(16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '問題文 (Question):',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  const Gap(4),
                  Text(
                    question,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  if (isTranslationLoading) ...[
                    const Gap(12),
                    Text(
                      '和訳 (Japanese Translation):',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.secondary),
                    ),
                    const Gap(6),
                    const Row(
                      children: [
                        SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        Gap(8),
                        Text(
                          '和訳を生成中...',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ] else if (translation != null && translation.isNotEmpty) ...[
                    const Gap(8),
                    Text(
                      '和訳 (Japanese Translation):',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.secondary),
                    ),
                    const Gap(4),
                    Text(
                      translation,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const Gap(16),
          const Divider(),
          const Gap(8),
          Text(
            explanationJa,
            style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color, height: 1.5),
          ),
        ],
      ),
    );
  }
}
