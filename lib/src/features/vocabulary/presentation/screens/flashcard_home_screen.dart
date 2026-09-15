import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../controllers/flashcard_controller.dart';
import '../../domain/entities/flashcard.dart';

class FlashcardHomeScreen extends ConsumerStatefulWidget {
  const FlashcardHomeScreen({super.key});

  @override
  ConsumerState<FlashcardHomeScreen> createState() => _FlashcardHomeScreenState();
}

class _FlashcardHomeScreenState extends ConsumerState<FlashcardHomeScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedCardIds = {};

  List<Flashcard> _getManagedCards(FlashcardState state) {
    var cards = state.allCards
        .where((c) => c.source == FlashcardSource.user || c.source == FlashcardSource.ai)
        .toList();
    if (state.selectedCategory != null) {
      if (state.selectedCategory == 'AI生成') {
        cards = cards
            .where((c) => c.source == FlashcardSource.ai || c.category == 'AI生成')
            .toList();
      } else {
        cards = cards.where((c) => c.category == state.selectedCategory).toList();
      }
    }
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flashcardControllerProvider);
    final controller = ref.read(flashcardControllerProvider.notifier);
    final theme = Theme.of(context);

    final managedCards = _getManagedCards(state);

    // Prune selected IDs that are no longer present in managedCards
    final managedIds = managedCards.map((c) => c.id).toSet();
    _selectedCardIds.removeWhere((id) => !managedIds.contains(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('金融英語単語カード'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fact_check_outlined),
            tooltip: '単語一覧',
            onPressed: () => context.push('/flashcards/review-list'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '単語を追加',
            onPressed: () => context.push('/flashcards/add'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Stats Card ---
                  _buildStatsCard(context, state),
                  const Gap(20),

                  // --- Category Filter ---
                  Text(
                    'カテゴリー選択',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  _buildCategoryFilter(context, state, controller),
                  const Gap(20),

                  // --- Session Modes ---
                  Text(
                    '学習モードを選択',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(12),

                  _buildModeCard(
                    context,
                    title: '単語一覧',
                    subtitle: '全単語の検索・一括閲覧・習得ステータス切り替え',
                    icon: Icons.fact_check,
                    color: Colors.teal,
                    onTap: () => context.push('/flashcards/review-list'),
                  ),
                  const Gap(10),

                  _buildModeCard(
                    context,
                    title: 'すべてのカードを復習',
                    subtitle: '${state.selectedCategory ?? "全カテゴリー"} (${state.filteredTotalCount}語)',
                    icon: Icons.style,
                    color: Colors.blue,
                    onTap: state.filteredTotalCount == 0
                        ? null
                        : () {
                            controller.startSession(FlashcardSessionMode.all);
                            context.push('/flashcards/session');
                          },
                  ),
                  const Gap(10),

                  _buildModeCard(
                    context,
                    title: '未習得単語の集中復習',
                    subtitle: '${state.selectedCategory != null ? "${state.selectedCategory}の" : ""}未習得カード (${state.filteredUnlearnedCount}語)',
                    icon: Icons.repeat_one,
                    color: Colors.orange,
                    onTap: state.filteredUnlearnedCount == 0
                        ? null
                        : () {
                            controller.startSession(FlashcardSessionMode.unlearned);
                            context.push('/flashcards/session');
                          },
                  ),
                  const Gap(24),

                  // --- User & AI Cards List Header ---
                  _buildUserCardsHeader(context, state, controller, managedCards),
                  const Gap(8),
                  _buildUserCardsList(context, state, controller, managedCards),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard(BuildContext context, FlashcardState state) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '学習進捗',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  state.selectedCategory != null
                      ? '${state.selectedCategory} (${state.filteredTotalCount} 語)'
                      : '全 ${state.filteredTotalCount} 語',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Gap(12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    if (state.filteredMasteredPercent > 0)
                      Expanded(
                        flex: (state.filteredMasteredPercent * 100).round(),
                        child: Container(color: Colors.green),
                      ),
                    if (state.filteredLearningPercent > 0)
                      Expanded(
                        flex: (state.filteredLearningPercent * 100).round(),
                        child: Container(color: Colors.orange),
                      ),
                    if (state.filteredNewPercent > 0)
                      Expanded(
                        flex: (state.filteredNewPercent * 100).round(),
                        child: Container(color: Colors.grey.shade300),
                      ),
                  ],
                ),
              ),
            ),
            const Gap(14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBadge('習得済み', state.filteredMasteredCount, Colors.green),
                _buildStatBadge('学習中', state.filteredLearningCount, Colors.orange),
                _buildStatBadge('未着手', state.filteredNewCount, Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, int count, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const Gap(4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
        const Gap(2),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(
    BuildContext context,
    FlashcardState state,
    FlashcardController controller,
  ) {
    final categories = ['すべて', ...state.categories];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == 'すべて'
              ? state.selectedCategory == null
              : state.selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              selected: isSelected,
              label: Text(cat),
              onSelected: (_) {
                controller.setCategory(cat == 'すべて' ? null : cat);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        enabled: onTap != null,
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildUserCardsHeader(
    BuildContext context,
    FlashcardState state,
    FlashcardController controller,
    List<Flashcard> managedCards,
  ) {
    final theme = Theme.of(context);

    if (_isSelectionMode) {
      final allSelected = managedCards.isNotEmpty &&
          _selectedCardIds.length == managedCards.length;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: allSelected,
              tristate: _selectedCardIds.isNotEmpty && !allSelected,
              onChanged: (bool? checked) {
                setState(() {
                  if (checked == true) {
                    _selectedCardIds.addAll(managedCards.map((c) => c.id));
                  } else {
                    _selectedCardIds.clear();
                  }
                });
              },
            ),
            Text(
              '全選択 (${_selectedCardIds.length}/${managedCards.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _selectedCardIds.isEmpty
                  ? null
                  : () => _confirmBulkDelete(context, controller, managedCards),
              icon: Icon(
                Icons.delete_forever,
                color: _selectedCardIds.isEmpty ? Colors.grey : Colors.red,
                size: 20,
              ),
              label: Text(
                '一括削除 (${_selectedCardIds.length})',
                style: TextStyle(
                  color: _selectedCardIds.isEmpty ? Colors.grey : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'キャンセル',
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedCardIds.clear();
                });
              },
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            '登録カスタム単語一覧',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (managedCards.isNotEmpty) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = true;
                    _selectedCardIds.clear();
                  });
                },
                icon: const Icon(Icons.checklist, size: 18),
                label: const Text('選択削除'),
              ),
              const Gap(8),
            ],
            TextButton.icon(
              onPressed: () => context.push('/flashcards/add'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('追加'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserCardsList(
    BuildContext context,
    FlashcardState state,
    FlashcardController controller,
    List<Flashcard> managedCards,
  ) {
    if (managedCards.isEmpty) {
      return Card(
        color: Colors.grey.shade50,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              '追加したカスタム単語カードはまだありません。\n右上または「追加」ボタンから新しい単語を追加できます。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: managedCards.length,
      separatorBuilder: (ctx, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final card = managedCards[index];
        final isSelected = _selectedCardIds.contains(card.id);

        return ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: _isSelectionMode ? 4 : 16,
            vertical: 0,
          ),
          onTap: _isSelectionMode
              ? () {
                  setState(() {
                    if (isSelected) {
                      _selectedCardIds.remove(card.id);
                    } else {
                      _selectedCardIds.add(card.id);
                    }
                  });
                }
              : null,
          leading: _isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (bool? checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedCardIds.add(card.id);
                      } else {
                        _selectedCardIds.remove(card.id);
                      }
                    });
                  },
                )
              : null,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  card.term,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Gap(8),
              _buildManagedCardBadge(card.source),
            ],
          ),
          subtitle: Text('${card.meaning} (${card.category})'),
          trailing: _isSelectionMode
              ? null
              : IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, controller, card),
                ),
        );
      },
    );
  }

  Widget _buildManagedCardBadge(FlashcardSource source) {
    if (source == FlashcardSource.ai) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple.shade200),
        ),
        child: const Text(
          'AI生成',
          style: TextStyle(
            fontSize: 10,
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (source == FlashcardSource.user) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal.shade200),
        ),
        child: const Text(
          'カスタム',
          style: TextStyle(
            fontSize: 10,
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _confirmDelete(
    BuildContext context,
    FlashcardController controller,
    Flashcard card,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('単語の削除'),
        content: Text('「${card.term}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteUserCard(card.id);
              Navigator.pop(ctx);
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmBulkDelete(
    BuildContext context,
    FlashcardController controller,
    List<Flashcard> managedCards,
  ) {
    final count = _selectedCardIds.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('単語の一括削除'),
        content: Text('選択した $count 件の単語カードを削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final idsToDelete = _selectedCardIds.toList();
              await controller.deleteUserCards(idsToDelete);
              if (mounted) {
                setState(() {
                  _isSelectionMode = false;
                  _selectedCardIds.clear();
                });
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('$count 件の単語を削除しました'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text(
              '一括削除',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
