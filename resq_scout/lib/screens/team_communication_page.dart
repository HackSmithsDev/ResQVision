import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router/app_router.dart';
import '../models/chat_message.dart';
import '../providers/communication_provider.dart';
import '../widgets/rescue_widgets.dart';

class TeamCommunicationPage extends ConsumerStatefulWidget {
  const TeamCommunicationPage({super.key});

  @override
  ConsumerState<TeamCommunicationPage> createState() =>
      _TeamCommunicationPageState();
}

class _TeamCommunicationPageState extends ConsumerState<TeamCommunicationPage> {
  final _composerController = TextEditingController();
  final _scrollController = ScrollController();
  ChatChannel _channel = ChatChannel.team;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectChannel(ChatChannel channel) {
    if (channel == _channel) return;
    setState(() => _channel = channel);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
  }

  void _sendMessage() {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;
    ref
        .read(communicationProvider.notifier)
        .sendMessage(_channel, text, _timeNow());
    _composerController.clear();
    _scrollToLatest();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(communicationProvider).messagesFor(_channel);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(
              title: 'Team Communication',
              subtitle: 'Rescue B27 • Uttarkashi',
              status: _channel == ChatChannel.team
                  ? '8 members active'
                  : 'Control online',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: _ChannelSelector(
                channel: _channel,
                onChanged: _selectChannel,
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                itemCount: messages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) => _ChatEntryView(
                  entry: messages[index],
                  onOpenMap: () => context.push(AppRoutes.rescueMode),
                ),
              ),
            ),
            _MessageComposer(
              controller: _composerController,
              hintText: 'Type a message...',
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String status;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 10, 18, 10),
    child: Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900, color: ink),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
              ),
            ],
          ),
        ),
        const Icon(Icons.circle, size: 11, color: Color(0xFF18AE73)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            status,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF476185), fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class _ChannelSelector extends StatelessWidget {
  const _ChannelSelector({required this.channel, required this.onChanged});
  final ChatChannel channel;
  final ValueChanged<ChatChannel> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _channelCard(
          ChatChannel.team,
          Icons.groups_rounded,
          'Team Alpha',
          '5 members',
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _channelCard(
          ChatChannel.control,
          Icons.headset_mic_rounded,
          'Control Room',
          'Central command',
        ),
      ),
    ],
  );

  Widget _channelCard(
    ChatChannel value,
    IconData icon,
    String title,
    String detail,
  ) {
    final selected = value == channel;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F2FF) : const Color(0xFFF0F4FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFF2878E6) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? const Color(0xFF1765CF)
                    : const Color(0xFF476185),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: selected ? const Color(0xFF124B9D) : ink,
                      ),
                    ),
                    Text(
                      detail,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatEntryView extends StatelessWidget {
  const _ChatEntryView({required this.entry, required this.onOpenMap});
  final ChatMessage entry;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    if (entry.isMine) {
      return Align(
        alignment: Alignment.centerRight,
        child: _bubble(context, entry.message, true),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Color(entry.avatarColorValue ?? 0xFFDCE8FB),
          child: Text(
            entry.initials ?? 'R',
            style: const TextStyle(fontWeight: FontWeight.w800, color: ink),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.sender,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1765CF),
                      ),
                    ),
                  ),
                  Text(
                    entry.timestamp,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              if (entry.type == ChatMessageType.location)
                _LocationMessageCard(entry: entry, onOpenMap: onOpenMap)
              else if (entry.type == ChatMessageType.hazard)
                _HazardMessageCard(entry: entry)
              else
                _bubble(context, entry.message, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bubble(BuildContext context, String text, bool isMine) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: isMine ? const Color(0xFFDDEEFF) : const Color(0xFFF0F3F8),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(text, style: const TextStyle(color: ink)),
        if (isMine)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              entry.timestamp,
              style: const TextStyle(color: Color(0xFF476185), fontSize: 11),
            ),
          ),
      ],
    ),
  );
}

class _LocationMessageCard extends StatelessWidget {
  const _LocationMessageCard({required this.entry, required this.onOpenMap});
  final ChatMessage entry;
  final VoidCallback onOpenMap;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F5FC),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFDCE8FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: Color(0xFFD52C3E),
            size: 30,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.cardTitle ?? '',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                entry.cardDescription ?? '',
                style: const TextStyle(fontSize: 12, color: Color(0xFF476185)),
              ),
              TextButton.icon(
                onPressed: onOpenMap,
                icon: const Icon(Icons.map_outlined, size: 17),
                label: const Text('View on Map'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(top: 3),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HazardMessageCard extends StatelessWidget {
  const _HazardMessageCard({required this.entry});
  final ChatMessage entry;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFEAEC),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFFFC5CC)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFD52C3E),
          size: 30,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.cardTitle ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD52C3E),
                ),
              ),
              Text(
                entry.cardDescription ?? '',
                style: const TextStyle(color: Color(0xFF8E3340)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.hintText,
    required this.onSend,
  });
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSend;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 8,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.attach_file_rounded,
                color: Color(0xFF1765CF),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: hintText,
                  isDense: true,
                  suffixIcon: const Icon(Icons.mic_none_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF4F7FC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFF2878E6),
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _timeNow() {
  final now = TimeOfDay.now();
  final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
  return '$hour:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'AM' : 'PM'}';
}
