class ChatReplyOption {
  final String text;
  final String? label;
  final String? translationJa;
  final List<ChatReplyOption>? nextOptions;
  final List<String>? aiReplies; // Fixed AI reply candidates (1 is picked at random per turn)

  const ChatReplyOption({
    required this.text,
    this.label,
    this.translationJa,
    this.nextOptions,
    this.aiReplies,
  });
}
