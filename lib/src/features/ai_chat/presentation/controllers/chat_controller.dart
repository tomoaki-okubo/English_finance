import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/persona.dart';
import '../../domain/entities/chat_reply_option.dart';
import '../../data/sources/roleplay_scenarios_data.dart';
import '../../../dashboard/presentation/controllers/training_activity_controller.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isGenerating;
  final String? streamingBuffer;
  final Persona activePersona;
  final RoleplayScenario currentScenario;
  final int currentTurnIndex;
  final List<ChatReplyOption> currentOptions;
  final bool isScenarioCompleted;

  ChatState({
    required this.messages,
    required this.isGenerating,
    this.streamingBuffer,
    required this.activePersona,
    required this.currentScenario,
    required this.currentTurnIndex,
    required this.currentOptions,
    required this.isScenarioCompleted,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isGenerating,
    String? streamingBuffer,
    Persona? activePersona,
    RoleplayScenario? currentScenario,
    int? currentTurnIndex,
    List<ChatReplyOption>? currentOptions,
    bool? isScenarioCompleted,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      streamingBuffer: streamingBuffer ?? this.streamingBuffer,
      activePersona: activePersona ?? this.activePersona,
      currentScenario: currentScenario ?? this.currentScenario,
      currentTurnIndex: currentTurnIndex ?? this.currentTurnIndex,
      currentOptions: currentOptions ?? this.currentOptions,
      isScenarioCompleted: isScenarioCompleted ?? this.isScenarioCompleted,
    );
  }

  ChatState clearStreamingBuffer() {
    return ChatState(
      messages: messages,
      isGenerating: isGenerating,
      streamingBuffer: null,
      activePersona: activePersona,
      currentScenario: currentScenario,
      currentTurnIndex: currentTurnIndex,
      currentOptions: currentOptions,
      isScenarioCompleted: isScenarioCompleted,
    );
  }
}

final chatControllerProvider = NotifierProvider.autoDispose<ChatController, ChatState>(() {
  return ChatController();
});

// Default fallback replies per persona in case aiReplies is not set
const Map<String, List<String>> _fallbackReplies = {
  'banker': [
    "Good point! I'll update the financial model accordingly.",
    "Understood. Let me review the deal terms and get back to you.",
    "Sure, I'll prepare the analysis and send it over shortly.",
  ],
  'risk': [
    "Noted! I'll include that in our risk assessment.",
    "Understood. I'll run the stress test with those parameters.",
    "Good point. I'll update the risk exposure report.",
  ],
  'fund': [
    "Got it! I'll review the portfolio allocation accordingly.",
    "Understood. I'll run the attribution analysis and report back.",
    "Good call. I'll adjust the investment strategy to reflect that.",
  ],
  'compliance': [
    "Noted! I'll update the compliance checklist.",
    "Understood. I'll review the regulatory requirements and advise.",
    "Good point. I'll ensure our policies address that concern.",
  ],
  'customer': [
    "Thank you for explaining that! It's very helpful.",
    "I see, that makes sense. What should I do next?",
    "I appreciate your patience in explaining this to me.",
  ],
};

class ChatController extends AutoDisposeNotifier<ChatState> {
  Timer? _typingTimer;
  final _random = Random();

  static const Persona bankerPersona = Persona(
    id: 'banker',
    name: 'Investment Banker (James)',
    roleDescription: 'M&A Advisory & Capital Markets',
    systemPrompt: '''You are James, a senior investment banker practicing English with a finance professional.

Reply in plain professional English, one or two sentences, maximum 30 words.

Choose exactly one rule:
1. If the request involves regulatory filings or legal work, say that belongs to the legal and compliance teams and offer financial analysis support.
2. Otherwise, if the request involves aggressive or unsupported valuations, say it risks deal credibility and propose data-driven valuation approaches.
3. Otherwise, answer the latest deal or capital markets inquiry naturally. Discuss M&A structuring, IPO pricing, financial modeling, or deal execution.

Example user: Let's just offer 30% below the asking price without any analysis.
Example assistant: An unsupported lowball offer damages our credibility. Let us build a DCF and comparable transactions analysis first.

Example user: Can you handle the regulatory filings for the cross-border deal?
Example assistant: Regulatory filings are handled by our legal team. I can provide the financial analysis they need for the filings.''',
    avatarUrl: '',
  );

  static const Persona riskAnalystPersona = Persona(
    id: 'risk',
    name: 'Risk Analyst (Sarah)',
    roleDescription: 'Credit & Market Risk Management',
    systemPrompt: '''You are Sarah, a senior risk analyst practicing English with a finance professional.

Reply in plain professional English, one or two sentences, maximum 30 words.

Choose exactly one rule:
1. If asked to relax risk limits or ignore risk metrics, say it undermines risk governance and propose proper remediation or escalation.
2. Otherwise, if asked to use stale data or skip model validation, say it violates model governance requirements and propose using current data.
3. Otherwise, answer the latest risk management inquiry naturally. Discuss credit risk, stress testing, VaR, or portfolio risk metrics.

Example user: Can you just raise the concentration limit so we don't have a breach?
Example assistant: Adjusting limits to avoid breaches undermines risk governance. We should reduce actual exposure and report to the Risk Committee.

Example user: Use last year's stress test model without updating the data.
Example assistant: Using stale data violates model governance requirements. We must use current portfolio data for accurate results.''',
    avatarUrl: '',
  );

  static const Persona fundManagerPersona = Persona(
    id: 'fund',
    name: 'Fund Manager (David)',
    roleDescription: 'Portfolio Management & Asset Allocation',
    systemPrompt: '''You are David, a senior fund manager practicing English with a finance professional.

Reply in plain professional English, one or two sentences, maximum 30 words.

Choose exactly one rule:
1. If asked to take excessive risk or chase unrealistic returns, say it violates the fund mandate and fiduciary duty. Propose disciplined risk-adjusted approaches.
2. Otherwise, if asked to ignore ESG criteria or diversification principles, say it conflicts with investment policy. Propose compliant alternatives.
3. Otherwise, answer the latest portfolio management inquiry naturally. Discuss asset allocation, performance attribution, rebalancing, or fund strategy.

Example user: Can we take on much more risk to push for 15% returns next quarter?
Example assistant: Chasing excessive returns violates our fund mandate. Our current risk-adjusted performance is already top-quartile among peers.

Example user: Ignore the ESG screening for this mandate.
Example assistant: We cannot ignore ESG criteria — it is part of the client's investment policy. Let me propose compliant alternatives.''',
    avatarUrl: '',
  );

  static const Persona complianceOfficerPersona = Persona(
    id: 'compliance',
    name: 'Compliance Officer (Lisa)',
    roleDescription: 'Regulatory Compliance & AML',
    systemPrompt: '''You are Lisa, a senior compliance officer practicing English with a finance professional.

Reply in plain professional English, one or two sentences, maximum 30 words.

Choose exactly one rule:
1. If asked to dismiss AML alerts or ignore suspicious transactions, say it is a serious regulatory violation and propose proper investigation procedures.
2. Otherwise, if asked to copy generic policies or skip compliance training, say it fails regulatory scrutiny and propose tailored, risk-based approaches.
3. Otherwise, answer the latest compliance or regulatory inquiry naturally. Discuss AML, KYC, sanctions screening, or regulatory reporting.

Example user: Let's just clear this AML alert without investigating.
Example assistant: Dismissing AML alerts without investigation is a regulatory violation. We must investigate and file a SAR if warranted.

Example user: Can you copy another bank's compliance policy for our use?
Example assistant: Generic copied policies fail regulatory scrutiny. Our framework must reflect our specific risk profile and business model.''',
    avatarUrl: '',
  );

  static const Persona customerPersona = Persona(
    id: 'customer',
    name: 'Customer (Yuki)',
    roleDescription: 'General Banking Customer',
    systemPrompt: '''You are Yuki, a general banking customer practicing English in a bank consultation setting.

Reply in plain professional English, one or two sentences, maximum 30 words.

Choose exactly one rule:
1. If given risky or aggressive financial advice without proper consideration, express concern and ask for safer alternatives.
2. Otherwise, if the banker uses complex jargon, ask for a simpler explanation.
3. Otherwise, respond naturally as a customer discussing account opening, mortgages, savings, or other banking needs.

Example user: You should invest all your savings in our highest-risk product.
Example assistant: That sounds very risky. Shouldn't I keep some money accessible for emergencies? I'd prefer a safer approach.

Example user: The amortization schedule reflects the principal reduction over the tenor.
Example assistant: I'm not sure I understand all those terms. Could you explain that in simpler words?''',
    avatarUrl: '',
  );

  @override
  ChatState build() {
    ref.onDispose(() {
      _typingTimer?.cancel();
    });

    final initialScenario = RoleplayScenariosData.getInitialScenarioFor('banker');
    final initialGreeting = ChatMessage.ai(content: initialScenario.initialAiGreeting);
    final initialOptions = initialScenario.initialOptions;

    return ChatState(
      messages: [initialGreeting],
      isGenerating: false,
      activePersona: bankerPersona,
      currentScenario: initialScenario,
      currentTurnIndex: 0,
      currentOptions: initialOptions,
      isScenarioCompleted: false,
    );
  }

  Future<void> switchPersona(Persona newPersona) async {
    if (state.activePersona.id == newPersona.id && state.messages.isNotEmpty) return;
    _typingTimer?.cancel();

    final nextScenario = RoleplayScenariosData.getInitialScenarioFor(newPersona.id);
    final initialGreeting = ChatMessage.ai(content: nextScenario.initialAiGreeting);
    final initialOptions = nextScenario.initialOptions;

    state = state.clearStreamingBuffer().copyWith(
      activePersona: newPersona,
      currentScenario: nextScenario,
      currentTurnIndex: 0,
      currentOptions: initialOptions,
      messages: [initialGreeting],
      isGenerating: false,
      isScenarioCompleted: false,
    );
  }

  static const Map<String, Persona> allPersonas = {
    'banker': bankerPersona,
    'risk': riskAnalystPersona,
    'fund': fundManagerPersona,
    'compliance': complianceOfficerPersona,
    'customer': customerPersona,
  };

  Future<void> startScenario(RoleplayScenario scenario) async {
    _typingTimer?.cancel();

    final targetPersona = allPersonas[scenario.personaId] ?? bankerPersona;
    final initialGreeting = ChatMessage.ai(content: scenario.initialAiGreeting);
    final initialOptions = scenario.initialOptions;

    state = state.clearStreamingBuffer().copyWith(
      activePersona: targetPersona,
      currentScenario: scenario,
      currentTurnIndex: 0,
      currentOptions: initialOptions,
      messages: [initialGreeting],
      isGenerating: false,
      isScenarioCompleted: false,
    );
  }

  Future<void> nextScenario() async {
    final allScenarios = RoleplayScenariosData.scenarios.where((s) => s.personaId == state.activePersona.id).toList();
    final currentIndex = allScenarios.indexWhere((s) => s.id == state.currentScenario.id);
    final nextIndex = (currentIndex + 1) % allScenarios.length;
    await startScenario(allScenarios[nextIndex]);
  }

  Future<void> restartCurrentScenario() async {
    await startScenario(state.currentScenario);
  }

  Future<void> selectReplyOption(ChatReplyOption option) async {
    if (state.isGenerating) return;

    final userMsg = ChatMessage.user(content: option.text);
    final nextTurnIndex = state.currentTurnIndex + 1;

    // Record training activity on dashboard calendar
    ref.read(trainingActivityControllerProvider.notifier).recordActivity(chatTurns: 1);

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isGenerating: true,
    );

    // Pick a fixed AI reply: use aiReplies from scenario data, else fallback
    final candidates = (option.aiReplies != null && option.aiReplies!.isNotEmpty)
        ? option.aiReplies!
        : (_fallbackReplies[state.activePersona.id] ?? ['Understood.']);
    final replyText = candidates[_random.nextInt(candidates.length)];

    // Simulate typing with character-by-character streaming animation
    _simulateTyping(
      text: replyText,
      onDone: () {
        final nextOptions = option.nextOptions ?? <ChatReplyOption>[];
        final hasNext = nextOptions.isNotEmpty;

        final aiMsg = ChatMessage.ai(content: replyText);
        state = state.clearStreamingBuffer().copyWith(
          messages: [...state.messages, aiMsg],
          isGenerating: false,
          currentTurnIndex: nextTurnIndex,
          currentOptions: nextOptions,
          isScenarioCompleted: !hasNext,
        );
      },
    );
  }

  void _simulateTyping({required String text, required VoidCallback onDone}) {
    _typingTimer?.cancel();
    int charIndex = 0;
    // Reset streaming buffer to start fresh
    state = state.copyWith(streamingBuffer: '');

    const charDelay = Duration(milliseconds: 22);
    _typingTimer = Timer.periodic(charDelay, (timer) {
      if (charIndex >= text.length) {
        timer.cancel();
        onDone();
        return;
      }
      charIndex++;
      state = state.copyWith(streamingBuffer: text.substring(0, charIndex));
    });
  }
}

// VoidCallback type alias
typedef VoidCallback = void Function();
