class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.channel,
    required this.isMine,
    required this.type,
    this.initials,
    this.avatarColorValue,
    this.cardTitle,
    this.cardDescription,
  });

  final String id;
  final String sender;
  final String message;
  final String timestamp;
  final ChatChannel channel;
  final bool isMine;
  final ChatMessageType type;
  final String? initials;
  final int? avatarColorValue;
  final String? cardTitle;
  final String? cardDescription;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    sender: json['sender'] as String,
    message: json['message'] as String? ?? '',
    timestamp: json['timestamp'] as String,
    channel: ChatChannel.values.byName(json['channel'] as String),
    isMine: json['isMine'] as bool? ?? false,
    type: ChatMessageType.values.byName(json['type'] as String? ?? 'text'),
    initials: json['initials'] as String?,
    avatarColorValue: json['avatarColorValue'] as int?,
    cardTitle: json['cardTitle'] as String?,
    cardDescription: json['cardDescription'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender': sender,
    'message': message,
    'timestamp': timestamp,
    'channel': channel.name,
    'isMine': isMine,
    'type': type.name,
    'initials': initials,
    'avatarColorValue': avatarColorValue,
    'cardTitle': cardTitle,
    'cardDescription': cardDescription,
  };
}

enum ChatChannel { team, control }

enum ChatMessageType { text, location, hazard, voice }
