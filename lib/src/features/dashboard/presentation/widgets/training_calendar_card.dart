import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/daily_activity.dart';
import '../controllers/training_activity_controller.dart';

class TrainingCalendarCard extends ConsumerWidget {
  const TrainingCalendarCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(trainingActivityControllerProvider);
    final controller = ref.read(trainingActivityControllerProvider.notifier);

    final displayedMonth = state.displayedMonth;
    final selectedDate = state.selectedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final selectedActivity = state.selectedDayActivity;
    final isSelectedToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header: Month Navigation & Quick Today Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                      ),
                      const Gap(8),
                      Flexible(
                        child: Text(
                          '${displayedMonth.year}年 ${displayedMonth.month}月',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (displayedMonth.year != today.year ||
                        displayedMonth.month != today.month)
                      TextButton.icon(
                        onPressed: () => controller.goToToday(),
                        icon: const Icon(Icons.today_rounded, size: 13),
                        label: const Text('今月', style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    if (displayedMonth.year != today.year ||
                        displayedMonth.month != today.month)
                      const Gap(4),
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => controller.changeMonth(-1),
                      tooltip: '前月',
                    ),
                    const Gap(6),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => controller.changeMonth(1),
                      tooltip: '翌月',
                    ),
                  ],
                ),
              ],
            ),
            const Gap(14),

            // 2. Stats summary bar
            _buildStatsBar(context, state),
            const Gap(16),

            // 3. Days of week header
            _buildWeekHeader(context),
            const Gap(6),

            // 4. Calendar grid
            _buildCalendarGrid(context, ref, state),
            const Gap(12),

            // 5. Selected Day detail strip
            _buildSelectedDayDetail(
              context,
              selectedDate,
              isSelectedToday,
              selectedActivity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, TrainingActivityState state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.local_fire_department_rounded,
            color: Colors.deepOrange,
            title: '連続日数',
            value: '${state.currentStreak}日',
          ),
        ),
        const Gap(6),
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.event_available_rounded,
            color: Colors.blue.shade700,
            title: '今月学習',
            value: '${state.activeDaysThisMonth}日',
          ),
        ),
        const Gap(6),
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.bolt_rounded,
            color: Colors.purple.shade600,
            title: '総学習数',
            value: '${state.totalActivitiesCount}回',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const Gap(3),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const Gap(4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(BuildContext context) {
    const days = ['月', '火', '水', '木', '金', '土', '日'];
    return Row(
      children: List.generate(7, (index) {
        final isSat = index == 5;
        final isSun = index == 6;
        Color textColor = Colors.grey.shade600;
        if (isSat) textColor = Colors.blue.shade600;
        if (isSun) textColor = Colors.red.shade600;

        return Expanded(
          child: Center(
            child: Text(
              days[index],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    WidgetRef ref,
    TrainingActivityState state,
  ) {
    final theme = Theme.of(context);
    final displayedMonth = state.displayedMonth;
    final selectedDate = state.selectedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final controller = ref.read(trainingActivityControllerProvider.notifier);

    // Days calculation for Monday-based calendar
    final firstDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    
    // weekday in Dart: 1 = Monday, 7 = Sunday
    final leadingEmptyDays = (firstDayOfMonth.weekday - 1) % 7;
    final totalCells = ((leadingEmptyDays + daysInMonth + 6) ~/ 7) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1.1,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayOffset = index - leadingEmptyDays;
        final isCurrentMonthDay = dayOffset >= 0 && dayOffset < daysInMonth;

        DateTime cellDate;
        if (isCurrentMonthDay) {
          cellDate = DateTime(displayedMonth.year, displayedMonth.month, dayOffset + 1);
        } else if (dayOffset < 0) {
          cellDate = firstDayOfMonth.add(Duration(days: dayOffset));
        } else {
          cellDate = DateTime(displayedMonth.year, displayedMonth.month, daysInMonth)
              .add(Duration(days: dayOffset - daysInMonth + 1));
        }

        final cellKey = DailyActivity.formatDateKey(cellDate);
        final activity = state.activities[cellKey];
        final hasTraining = (activity?.totalCount ?? 0) > 0;

        final isToday = cellDate.year == today.year &&
            cellDate.month == today.month &&
            cellDate.day == today.day;
        final isSelected = cellDate.year == selectedDate.year &&
            cellDate.month == selectedDate.month &&
            cellDate.day == selectedDate.day;

        return InkWell(
          onTap: () {
            controller.selectDate(cellDate);
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: hasTraining
                  ? (isCurrentMonthDay
                      ? Colors.green.withValues(alpha: 0.18)
                      : Colors.green.withValues(alpha: 0.08))
                  : (isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.08)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isToday
                        ? Colors.deepOrange.withValues(alpha: 0.7)
                        : (hasTraining
                            ? Colors.green.withValues(alpha: 0.4)
                            : Colors.transparent)),
                width: isSelected ? 2 : (isToday ? 1.5 : 1),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${cellDate.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: (hasTraining || isToday || isSelected)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isCurrentMonthDay
                        ? (hasTraining
                            ? Colors.green.shade800
                            : (isToday ? Colors.deepOrange : null))
                        : Colors.grey.withValues(alpha: 0.4),
                  ),
                ),
                if (hasTraining)
                  Positioned(
                    bottom: 3,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayDetail(
    BuildContext context,
    DateTime selectedDate,
    bool isSelectedToday,
    DailyActivity? activity,
  ) {
    final theme = Theme.of(context);
    final hasTraining = (activity?.totalCount ?? 0) > 0;

    final dateLabel =
        '${selectedDate.month}月${selectedDate.day}日${isSelectedToday ? ' (今日)' : ''}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasTraining
            ? Colors.green.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasTraining
              ? Colors.green.withValues(alpha: 0.25)
              : theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasTraining
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: hasTraining ? Colors.green : Colors.grey,
            size: 22,
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Gap(2),
                if (hasTraining)
                  Text(
                    'ドリル: ${activity!.drillCount}問 / AIチャット: ${activity.chatTurnCount}回 (計 ${activity.totalCount}回完了 🎉)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    'この日のトレーニング記録はありません',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          if (hasTraining)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '完了',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
