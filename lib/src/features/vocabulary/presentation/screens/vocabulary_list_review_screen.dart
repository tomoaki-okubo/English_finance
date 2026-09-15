import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../controllers/flashcard_controller.dart';
import '../../domain/entities/flashcard.dart';

class VocabularyListReviewScreen extends ConsumerStatefulWidget {
  const VocabularyListReviewScreen({super.key});

  @override
  ConsumerState<VocabularyListReviewScreen> createState() =>
      _VocabularyListReviewScreenState();
}

class _VocabularyListReviewScreenState
    extends ConsumerState<VocabularyListReviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  FlashcardStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Flashcard> _filterCards(List<Flashcard> allCards) {
    return allCards.where((card) {
      // 1. Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTerm = card.term.toLowerCase().contains(query);
        final matchMeaning = card.meaning.toLowerCase().contains(query);
        final matchExample = card.example.toLowerCase().contains(query);
        final matchHint = card.hint.toLowerCase().contains(query);
        if (!matchTerm && !matchMeaning && !matchExample && !matchHint) {
          return false;
        }
      }

      // 2. Category filter
      if (_selectedCategory != null) {
        if (_selectedCategory == 'AI生成') {
          if (card.source != FlashcardSource.ai && card.category != 'AI生成') {
            return false;
          }
        } else if (_selectedCategory == 'カスタム') {
          if (card.source != FlashcardSource.user) {
            return false;
          }
        } else {
          if (card.category != _selectedCategory) {
            return false;
          }
        }
      }

      // 3. Status filter
      if (_selectedStatus != null) {
        if (card.status != _selectedStatus) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flashcardControllerProvider);
    final controller = ref.read(flashcardControllerProvider.notifier);
    final theme = Theme.of(context);

    final filteredList = _filterCards(state.allCards);

    return Scaffold(
      appBar: AppBar(
        title: const Text('単語一覧'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- Search & Filters Header ---
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search TextField
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '単語・意味・例文で検索...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const Gap(10),

                      // Category Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCategoryChip('すべて', null),
                            ...state.categories.map(
                              (cat) => _buildCategoryChip(cat, cat),
                            ),
                          ],
                        ),
                      ),
                      const Gap(8),

                      // Status Filter Chips & Counts
                      Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildStatusChip('すべて', null, Colors.blue),
                                  _buildStatusChip(
                                    '未着手',
                                    FlashcardStatus.newCard,
                                    Colors.grey,
                                  ),
                                  _buildStatusChip(
                                    '学習中',
                                    FlashcardStatus.learning,
                                    Colors.orange,
                                  ),
                                  _buildStatusChip(
                                    '習得済み',
                                    FlashcardStatus.mastered,
                                    Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            '${filteredList.length}/${state.allCards.length} 語',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // --- Word List ---
                Expanded(
                  child: filteredList.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredList.length,
                          separatorBuilder: (ctx, idx) => const Gap(12),
                          itemBuilder: (context, index) {
                            final card = filteredList[index];
                            return _buildWordCardItem(
                              context,
                              card,
                              controller,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label, style: const TextStyle(fontSize: 12)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  Widget _buildStatusChip(
      String label, FlashcardStatus? status, Color activeColor) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        selected: isSelected,
        selectedColor: activeColor.withValues(alpha: 0.2),
        checkmarkColor: activeColor,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? activeColor : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onSelected: (_) {
          setState(() {
            _selectedStatus = status;
          });
        },
      ),
    );
  }

  Widget _buildWordCardItem(
    BuildContext context,
    Flashcard card,
    FlashcardController controller,
  ) {
    final theme = Theme.of(context);

    Color statusColor;
    String statusLabel;
    switch (card.status) {
      case FlashcardStatus.mastered:
        statusColor = Colors.green;
        statusLabel = '習得済み';
        break;
      case FlashcardStatus.learning:
        statusColor = Colors.orange;
        statusLabel = '学習中';
        break;
      case FlashcardStatus.newCard:
        statusColor = Colors.grey;
        statusLabel = '未着手';
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Icon(
            card.status == FlashcardStatus.mastered
                ? Icons.check_circle
                : card.status == FlashcardStatus.learning
                    ? Icons.trending_up
                    : Icons.menu_book,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                card.term,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Gap(6),
            _buildSourceBadge(card.source),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(4),
            Text(
              card.meaning,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
            const Gap(4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    card.category,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          const Divider(),
          if (card.hint.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '💡 ヒント / 補足: ${card.hint}',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const Gap(8),
          ],
          if (card.example.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '例文:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    card.example,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (card.exampleTranslation.isNotEmpty) ...[
                    const Gap(4),
                    Text(
                      card.exampleTranslation,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Gap(12),
          ],

          // Quick status change buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ステータス変更:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildStatusToggleButton(
                    label: '未着手',
                    isSelected: card.status == FlashcardStatus.newCard,
                    activeColor: Colors.grey,
                    onTap: () => controller.updateCardStatus(
                      card.id,
                      FlashcardStatus.newCard,
                    ),
                  ),
                  const Gap(4),
                  _buildStatusToggleButton(
                    label: '学習中',
                    isSelected: card.status == FlashcardStatus.learning,
                    activeColor: Colors.orange,
                    onTap: () => controller.updateCardStatus(
                      card.id,
                      FlashcardStatus.learning,
                    ),
                  ),
                  const Gap(4),
                  _buildStatusToggleButton(
                    label: '習得済み',
                    isSelected: card.status == FlashcardStatus.mastered,
                    activeColor: Colors.green,
                    onTap: () => controller.updateCardStatus(
                      card.id,
                      FlashcardStatus.mastered,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggleButton({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade400,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? activeColor : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSourceBadge(FlashcardSource source) {
    if (source == FlashcardSource.ai) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(6),
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
          borderRadius: BorderRadius.circular(6),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const Gap(16),
            const Text(
              '該当する単語が見つかりませんでした',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const Gap(8),
            const Text(
              '検索条件やフィルターを変更してお試しください。',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
