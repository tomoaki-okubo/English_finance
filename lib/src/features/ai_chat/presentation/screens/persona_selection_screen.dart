import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../controllers/chat_controller.dart';

class PersonaSelectionScreen extends ConsumerWidget {
  const PersonaSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final personas = [
      _PersonaCardData(
        persona: ChatController.bankerPersona,
        icon: Icons.account_balance_rounded,
        color: Colors.indigo,
        scenarioCount: 2,
        descriptionJa: 'M&A案件・IPO・資金調達について議論',
      ),
      _PersonaCardData(
        persona: ChatController.riskAnalystPersona,
        icon: Icons.shield_rounded,
        color: Colors.red.shade700,
        scenarioCount: 2,
        descriptionJa: 'リスク管理・ストレステスト・規制対応について議論',
      ),
      _PersonaCardData(
        persona: ChatController.fundManagerPersona,
        icon: Icons.trending_up_rounded,
        color: Colors.teal,
        scenarioCount: 2,
        descriptionJa: '運用戦略・ポートフォリオ・ESG投資について議論',
      ),
      _PersonaCardData(
        persona: ChatController.complianceOfficerPersona,
        icon: Icons.gavel_rounded,
        color: Colors.amber.shade800,
        scenarioCount: 2,
        descriptionJa: 'AML・KYC・規制遵守について議論',
      ),
      _PersonaCardData(
        persona: ChatController.customerPersona,
        icon: Icons.person_rounded,
        color: Colors.green.shade700,
        scenarioCount: 2,
        descriptionJa: '口座開設・住宅ローン相談・貯蓄プランの対応',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat & Roleplay'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.people_alt_outlined,
                size: 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
              const Gap(12),
              Text(
                'チャット相手を選んでください',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Gap(4),
              Text(
                'Select a finance professional to practice English roleplay',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const Gap(24),
              ...personas.map((data) => Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: _buildPersonaCard(context, theme, data),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonaCard(
    BuildContext context,
    ThemeData theme,
    _PersonaCardData data,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: data.color.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () {
          context.push('/chat/${data.persona.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: data.color, size: 30),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.persona.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      data.persona.roleDescription,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: data.color,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      data.descriptionJa,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Gap(6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${data.scenarioCount} scenarios',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonaCardData {
  final dynamic persona;
  final IconData icon;
  final Color color;
  final int scenarioCount;
  final String descriptionJa;

  const _PersonaCardData({
    required this.persona,
    required this.icon,
    required this.color,
    required this.scenarioCount,
    required this.descriptionJa,
  });
}
