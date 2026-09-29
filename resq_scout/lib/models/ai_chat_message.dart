class AIChatMessage {
  const AIChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
  });
  final String id;
  final String text;
  final bool isUser;

  factory AIChatMessage.fromJson(Map<String, dynamic> json) => AIChatMessage(
    id: json['id'] as String,
    text: json['text'] as String,
    isUser: json['isUser'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'isUser': isUser};
}
