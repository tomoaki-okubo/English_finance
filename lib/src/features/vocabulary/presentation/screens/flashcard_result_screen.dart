import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../controllers/flashcard_controller.dart';

class FlashcardResultScreen extends ConsumerWidget {
  const FlashcardResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(flashcardControllerProvider);
    final controller = ref.read(flashcardControllerProvider.notifier);
    final theme = Theme.of(context);

    final totalSession = state.sessionKnownCount + state.sessionUnknownCount;
    final accuracyPercent =
        totalSession > 0 ? (state.sessionKnownCount / totalSession * 100).round() : 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go('/flashcards');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('セッション結果'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(20),
              const Icon(
                Icons.military_tech,
                size: 80,
                color: Colors.amber,
              ),
              const Gap(12),
              Text(
                'お疲れ様でした！',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(6),
              Text(
                '学習セッションが完了しました。',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const Gap(32),

              // Results Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        '定着度 $accuracyPercent%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Gap(16),
                      const Divider(),
                      const Gap(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildResultStat(
                            label: '覚えた！',
                            count: state.sessionKnownCount,
                            color: Colors.green,
                            icon: Icons.check_circle_outline,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          _buildResultStat(
                            label: '要復習',
                            count: state.sessionUnknownCount,
                            color: Colors.orange,
                            icon: Icons.help_outline,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(32),

              // Action Buttons
              if (state.sessionUnknownCount > 0) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    controller.retryUnknownCards();
                    context.pushReplacement('/flashcards/session');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.orange, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.orange),
                  label: Text(
                    '要復習カード (${state.sessionUnknownCount}語) だけ再挑戦',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const Gap(12),
              ],

              ElevatedButton.icon(
                onPressed: () {
                  context.go('/flashcards');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  '単語カードTOPへ戻る',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const Gap(6),
        Text(
          '$count 語',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Gap(2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
