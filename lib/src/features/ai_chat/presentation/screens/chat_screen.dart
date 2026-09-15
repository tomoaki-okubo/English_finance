import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/persona.dart';
import '../../data/sources/roleplay_scenarios_data.dart';
import '../../../llm_engine/data/services/model_downloader_service.dart';
import '../../../llm_engine/domain/providers.dart';
import '../../../../core/services/ad_service.dart';
import '../controllers/chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String personaId;
  const ChatScreen({super.key, required this.personaId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  static const _personaMeta = <String, _PersonaMeta>{
    'dev': _PersonaMeta(Icons.code_rounded, Colors.blue, 'Alex (Dev): English only / Refuses manual QA'),
    'tester': _PersonaMeta(Icons.bug_report_rounded, Color(0xFFF9A825), 'Elena (QA): English only / Explains test suites & bugs'),
    'pm': _PersonaMeta(Icons.assignment_ind_outlined, Colors.teal, 'David (PM): English only / Sprint planning & stakeholder reports'),
    'ux': _PersonaMeta(Icons.design_services_outlined, Colors.deepPurple, 'Sophie (UX): English only / Design reviews & user flows'),
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      try {
        ref.read(llmEngineRepositoryProvider).dispose();
      } catch (_) {}
      final persona = ChatController.allPersonas[widget.personaId];
      if (persona != null) {
        ref.read(chatControllerProvider.notifier).switchPersona(persona);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final downloadState = ref.watch(modelDownloaderProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chatState.activePersona.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(chatState.currentScenario.title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.topic_outlined),
            tooltip: 'Select Scenario',
            onPressed: () => _showScenarioPicker(context, chatState),
          ),
          PopupMenuButton<Persona>(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Switch Partner',
            onSelected: (persona) {
              AdService.instance.showInterstitialAd(
                onAdDismissed: () {
                  ref.read(chatControllerProvider.notifier).switchPersona(persona);
                },
              );
            },
            itemBuilder: (context) => ChatController.allPersonas.values.map((persona) {
              final meta = _personaMeta[persona.id];
              return PopupMenuItem<Persona>(
                value: persona,
                child: Row(
                  children: [
                    Icon(meta?.icon ?? Icons.person, color: meta?.color ?? Colors.grey),
                    const Gap(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(persona.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(persona.roleDescription, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildPersonaBar(chatState.activePersona, chatState.currentScenario),
                if (downloadState.status != ModelDownloadStatus.ready)
                  _buildModelDownloadCard(downloadState),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16).copyWith(
                      bottom: !chatState.isScenarioCompleted
                          ? MediaQuery.of(context).size.height * 0.34
                          : 120,
                    ),
                    itemCount: chatState.messages.length + (chatState.isGenerating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < chatState.messages.length) {
                        final msg = chatState.messages[index];
                        return _buildMessageBubble(
                          text: msg.content,
                          isUser: msg.sender == MessageSender.user,
                          persona: chatState.activePersona,
                        );
                      } else {
                        return _buildTypingBubble(
                          text: chatState.streamingBuffer ?? '',
                          persona: chatState.activePersona,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            if (!chatState.isScenarioCompleted)
              _buildOptionsArea(chatState)
            else
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildCompletionBar(chatState),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaBar(Persona activePersona, RoleplayScenario scenario) {
    final meta = _personaMeta[activePersona.id] ?? _personaMeta['dev']!;

    return Container(
      color: meta.color.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(meta.icon, size: 20, color: meta.color),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: meta.color,
                  ),
                ),
                Text(
                  'Scenario: ${scenario.title}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelDownloadCard(ModelDownloadState state) {
    final theme = Theme.of(context);
    final isDownloading = state.status == ModelDownloadStatus.downloading;

    final percentText = (state.progress * 100).toStringAsFixed(1);
    final downloadedMB = (state.downloadedBytes / (1024 * 1024)).toStringAsFixed(1);
    final totalMB = (state.totalBytes / (1024 * 1024)).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_outlined, color: theme.colorScheme.primary, size: 22),
              const Gap(10),
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
                          : 'ローカルAIで会話するにはモデルが必要です',
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
            const Gap(8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: state.progress > 0 ? state.progress : null,
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

  Widget _buildMessageBubble({
    required String text,
    required bool isUser,
    required Persona persona,
  }) {
    final theme = Theme.of(context);
    final bubbleColor = isUser ? theme.colorScheme.primary : theme.cardColor;
    final textColor = isUser ? theme.colorScheme.onPrimary : theme.textTheme.bodyLarge?.color;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
          border: isUser ? null : Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(text, style: TextStyle(color: textColor, height: 1.4)),
      ),
    );
  }

  String _getDisplayName(String fullName) {
    final match = RegExp(r'\(([^)]+)\)').firstMatch(fullName);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    return fullName.split(' ').first;
  }

  Widget _buildTypingBubble({
    required String text,
    required Persona persona,
  }) {
    final theme = Theme.of(context);
    final meta = _personaMeta[persona.id] ?? _personaMeta['dev']!;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: const Radius.circular(0)),
          border: Border.all(color: meta.color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(meta.icon, size: 16, color: meta.color),
                const Gap(6),
                Text(
                  '${_getDisplayName(persona.name)} typing...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: meta.color,
                  ),
                ),
                const Gap(8),
                const _PulsingDots(),
              ],
            ),
            if (text.isNotEmpty) ...[
              const Gap(8),
              Text(text, style: TextStyle(color: theme.textTheme.bodyLarge?.color, height: 1.4)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionBar(ChatState chatState) {
    final theme = Theme.of(context);
    final controller = ref.read(chatControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              Gap(8),
              Text(
                'シナリオ完了！ (Scenario Completed)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    AdService.instance.showInterstitialAd(
                      onAdDismissed: () => controller.nextScenario(),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('次のシナリオへ'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              const Gap(8),
              OutlinedButton.icon(
                onPressed: () {
                  AdService.instance.showInterstitialAd(
                    onAdDismissed: () => controller.restartCurrentScenario(),
                  );
                },
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text('もう一度'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsArea(ChatState chatState) {
    final theme = Theme.of(context);
    final controller = ref.read(chatControllerProvider.notifier);

    final options = chatState.currentOptions;

    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.18,
      maxChildSize: 0.75,
      snap: true,
      snapSizes: const [0.32, 0.55, 0.75],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 6),
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.touch_app_rounded, size: 15, color: theme.colorScheme.primary),
                          const Gap(6),
                          Text(
                            '返信内容を選択してください',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                          ),
                          const Spacer(),
                          Icon(Icons.keyboard_arrow_up_rounded, size: 18, color: Colors.grey.shade500),
                          Text('スワイプで拡大', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    const Gap(8),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 14).copyWith(bottom: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final option = options[index];
                      // Determine label color
                      Color labelBg = Colors.orange.withValues(alpha: 0.1);
                      Color labelFg = Colors.orange.shade900;
                      if (option.label != null) {
                        final l = option.label!;
                        if (l.contains('Recommended') || l.contains('Constructive') ||
                            l.contains('Wrap') || l.contains('Best Practice') ||
                            l.contains('Proactive') || l.contains('Agile') ||
                            l.contains('Preparation') || l.contains('Process') ||
                            l.contains('Data-Driven') || l.contains('UX Best') ||
                            l.contains('Quality') || l.contains('Practical')) {
                          labelBg = Colors.green.withValues(alpha: 0.1);
                          labelFg = Colors.green.shade800;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: chatState.isGenerating
                              ? null
                              : () {
                                  controller.selectReplyOption(option);
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color ?? theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: chatState.isGenerating
                                    ? theme.dividerColor.withValues(alpha: 0.05)
                                    : theme.dividerColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  ),
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const Gap(10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option.text,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                          color: chatState.isGenerating ? Colors.grey : null,
                                        ),
                                      ),
                                      if (option.translationJa != null) ...[
                                        const Gap(4),
                                        Text(
                                          option.translationJa!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                      if (option.label != null) ...[
                                        const Gap(6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: labelBg,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            option.label!,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: labelFg,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: options.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showScenarioPicker(BuildContext context, ChatState state) {
    final controller = ref.read(chatControllerProvider.notifier);
    final personaScenarios = RoleplayScenariosData.scenarios.where((s) => s.personaId == state.activePersona.id).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20).copyWith(bottom: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${state.activePersona.name} のシナリオ一覧',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(16),
            ...personaScenarios.map((scenario) {
              final isCurrent = scenario.id == state.currentScenario.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: isCurrent ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : null,
                  leading: Icon(
                    isCurrent ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isCurrent ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                  title: Text(scenario.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(scenario.description, style: const TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    AdService.instance.showInterstitialAd(
                      onAdDismissed: () {
                        controller.startScenario(scenario);
                      },
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final opacity = ((val - (index * 0.25)) % 1.0).clamp(0.2, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}

class _PersonaMeta {
  final IconData icon;
  final Color color;
  final String subtitle;

  const _PersonaMeta(this.icon, this.color, this.subtitle);
}
