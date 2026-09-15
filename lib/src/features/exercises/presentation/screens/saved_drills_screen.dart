import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../controllers/saved_drills_controller.dart';
import '../../domain/entities/saved_drill_item.dart';
import '../../../correction/presentation/widgets/correction_modal.dart';

class SavedDrillsScreen extends ConsumerStatefulWidget {
  const SavedDrillsScreen({super.key});

  @override
  ConsumerState<SavedDrillsScreen> createState() => _SavedDrillsScreenState();
}

class _SavedDrillsScreenState extends ConsumerState<SavedDrillsScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Mistakes, 2: Bookmarks
  final Set<String> _expandedItemIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savedState = ref.watch(savedDrillsControllerProvider);
    final controller = ref.read(savedDrillsControllerProvider.notifier);

    List<SavedDrillItem> displayItems;
    if (_selectedFilterIndex == 1) {
      displayItems = savedState.mistakes;
    } else if (_selectedFilterIndex == 2) {
      displayItems = savedState.bookmarks;
    } else {
      displayItems = savedState.items;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('復習・見返しノート'),
        actions: [
          if (savedState.items.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (val) {
                if (val == 'clear_all') {
                  _showClearAllDialog(context, controller);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      Gap(8),
                      Text('すべて削除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Selector Segment
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SegmentedButton<int>(
                segments: [
                  ButtonSegment<int>(
                    value: 0,
                    label: Text('すべて (${savedState.items.length})'),
                    icon: const Icon(Icons.list_alt),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    label: Text('間違えた問題 (${savedState.mistakes.length})'),
                    icon: const Icon(Icons.cancel_outlined),
                  ),
                  ButtonSegment<int>(
                    value: 2,
                    label: Text('ブックマーク (${savedState.bookmarks.length})'),
                    icon: const Icon(Icons.bookmark_outline),
                  ),
                ],
                selected: {_selectedFilterIndex},
                onSelectionChanged: (set) {
                  setState(() {
                    _selectedFilterIndex = set.first;
                  });
                },
              ),
            ),
            const Divider(height: 1),

            // Content List or Empty State
            Expanded(
              child: displayItems.isEmpty
                  ? _buildEmptyState(theme, _selectedFilterIndex)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayItems.length,
                      itemBuilder: (context, index) {
                        final item = displayItems[index];
                        final isExpanded = _expandedItemIds.contains(item.id);
                        return _buildSavedCard(context, item, isExpanded, controller, theme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCard(
    BuildContext context,
    SavedDrillItem item,
    bool isExpanded,
    SavedDrillsController controller,
    ThemeData theme,
  ) {
    final formattedDate = '${item.savedAt.month}/${item.savedAt.day} ${item.savedAt.hour}:${item.savedAt.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: item.isMistake
              ? Colors.red.withValues(alpha: 0.3)
              : theme.dividerColor.withValues(alpha: 0.1),
          width: item.isMistake ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header: Badges & Bookmark Toggle & Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Category & Topic Badges
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.topic,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const Gap(4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    item.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: item.isBookmarked ? theme.colorScheme.primary : Colors.grey,
                  ),
                  tooltip: item.isBookmarked ? 'ブックマーク解除' : 'ブックマークに追加',
                  onPressed: () {
                    controller.toggleBookmark(item.toDrillQuestion());
                  },
                ),
              ],
            ),
            const Gap(12),

            // Mistake notice if user answered wrong
            if (item.isMistake && item.userAnswer != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 16),
                    const Gap(6),
                    Expanded(
                      child: Text(
                        'あなたの誤答: "${item.userAnswer}"',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
            ],

            // Question text
            Text(
              item.question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
            ),
            const Gap(16),

            // Toggle Expand / Collapse Explanation
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedItemIds.remove(item.id);
                  } else {
                    _expandedItemIds.add(item.id);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isExpanded ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const Gap(6),
                        Text(
                          isExpanded ? '正解と解説を隠す' : '正解と解説を確認する',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Explanation & Options
            if (isExpanded) ...[
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 18),
                        const Gap(6),
                        Text(
                          '正解: ${item.options[item.correctIndex]}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Text(
                      item.explanation,
                      style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],

            const Gap(12),
            // Bottom Action Row (Retry Quiz & Mastered/Delete)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _showRetryDialog(context, item, controller);
                  },
                  icon: const Icon(Icons.replay_rounded, size: 16),
                  label: const Text('解き直す', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const Gap(8),
                TextButton.icon(
                  onPressed: () {
                    controller.markAsMastered(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('復習リストから削除しました（克服完了！）'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: '元に戻す',
                          onPressed: () {
                            if (item.isMistake && item.userAnswer != null) {
                              controller.saveMistake(
                                drill: item.toDrillQuestion(),
                                userAnswer: item.userAnswer!,
                              );
                            } else {
                              controller.toggleBookmark(item.toDrillQuestion());
                            }
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_outlined, size: 16, color: Colors.grey),
                  label: const Text('克服・削除', style: TextStyle(fontSize: 13, color: Colors.grey)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRetryDialog(
    BuildContext context,
    SavedDrillItem item,
    SavedDrillsController controller,
  ) {
    int selectedOption = -1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24).copyWith(
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '再挑戦: ${item.topic}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Gap(12),
                Text(
                  item.question,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Gap(20),
                ...List.generate(item.options.length, (idx) {
                  final isSelected = selectedOption == idx;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () {
                        setModalState(() {
                          selectedOption = idx;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.12)
                              : theme.cardTheme.color ?? theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor.withValues(alpha: 0.15),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              String.fromCharCode(65 + idx),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? theme.colorScheme.primary : null,
                              ),
                            ),
                            const Gap(12),
                            Expanded(child: Text(item.options[idx], style: const TextStyle(fontSize: 15))),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const Gap(16),
                ElevatedButton(
                  onPressed: selectedOption == -1
                      ? null
                      : () {
                          Navigator.of(ctx).pop();
                          final isCorrect = selectedOption == item.correctIndex;
                          if (isCorrect) {
                            controller.markAsMastered(item.id);
                          }
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => CorrectionModal(
                              userAnswer: item.options[selectedOption],
                              correctAnswer: item.options[item.correctIndex],
                              isCorrect: isCorrect,
                              customExplanation: item.explanation,
                              question: item.question.replaceAll('_____', item.options[item.correctIndex]),
                              translation: item.translation,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('回答を送信', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, int filterIndex) {
    IconData icon;
    String title;
    String description;

    if (filterIndex == 1) {
      icon = Icons.check_circle_outline;
      title = '間違えた問題はありません！';
      description = '素晴らしい成果です！Drillを解いて苦手な分野を見つけましょう。';
    } else if (filterIndex == 2) {
      icon = Icons.bookmark_border;
      title = 'ブックマークはありません';
      description = '見返したい問題があれば、問題画面のブックマークボタンを押して保存できます。';
    } else {
      icon = Icons.folder_open_outlined;
      title = '保存された問題はありません';
      description = '間違えた問題やブックマークした問題がここに自動的に記録されます。';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: theme.colorScheme.primary),
            ),
            const Gap(20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, SavedDrillsController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('すべての問題を削除しますか？'),
        content: const Text('保存された間違えた問題やブックマークがすべて消去されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              controller.clearAll();
              Navigator.of(ctx).pop();
            },
            child: const Text('すべて削除'),
          ),
        ],
      ),
    );
  }
}
