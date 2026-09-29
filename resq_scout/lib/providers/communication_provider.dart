import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_communication_data.dart';
import '../models/chat_message.dart';

class CommunicationState {
  const CommunicationState({
    required this.teamMessages,
    required this.controlMessages,
  });

  final List<ChatMessage> teamMessages;
  final List<ChatMessage> controlMessages;

  List<ChatMessage> messagesFor(ChatChannel channel) =>
      channel == ChatChannel.team ? teamMessages : controlMessages;

  CommunicationState add(ChatMessage message) => CommunicationState(
    teamMessages: message.channel == ChatChannel.team
        ? [...teamMessages, message]
        : teamMessages,
    controlMessages: message.channel == ChatChannel.control
        ? [...controlMessages, message]
        : controlMessages,
  );
}

final communicationProvider =
    NotifierProvider<CommunicationNotifier, CommunicationState>(
      CommunicationNotifier.new,
    );

class CommunicationNotifier extends Notifier<CommunicationState> {
  @override
  CommunicationState build() => const CommunicationState(
    teamMessages: mockTeamMessages,
    controlMessages: mockControlMessages,
  );

  void sendMessage(ChatChannel channel, String text, String timestamp) {
    if (text.isEmpty) return;
    state = state.add(
      ChatMessage(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        sender: 'You',
        message: text,
        timestamp: timestamp,
        channel: channel,
        isMine: true,
        type: ChatMessageType.text,
      ),
    );

    Future<void>.delayed(const Duration(milliseconds: 700), () {
      state = state.add(mockCommunicationReply(channel, _timeNow()));
    });
  }
}

String _timeNow() {
  final now = DateTime.now();
  final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
  final period = now.hour < 12 ? 'AM' : 'PM';
  return '$hour:${now.minute.toString().padLeft(2, '0')} $period';
}
