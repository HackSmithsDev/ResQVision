import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_emergency_data.dart';
import '../models/emergency_action.dart';
import '../providers/rescue_session_provider.dart';
import 'emergency_hold_button.dart';
import 'emergency_voice_recorder.dart';

Future<void> showEmergencyActionBottomSheet({
  required BuildContext context,
  required EmergencyActionType type,
  VoidCallback? onViewMap,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) =>
      EmergencyActionBottomSheet(type: type, onViewMap: onViewMap),
);

class EmergencyActionBottomSheet extends ConsumerStatefulWidget {
  const EmergencyActionBottomSheet({
    super.key,
    required this.type,
    this.onViewMap,
  });

  final EmergencyActionType type;
  final VoidCallback? onViewMap;

  @override
  ConsumerState<EmergencyActionBottomSheet> createState() =>
      _EmergencyActionBottomSheetState();
}

enum _SheetStep { activate, details, confirmation }

class _EmergencyActionBottomSheetState
    extends ConsumerState<EmergencyActionBottomSheet> {
  late _SheetStep _step;
  VoiceRecording? _voiceRecording;

  EmergencyActionDetails get _details => actionDetailsFor(widget.type);

  @override
  void initState() {
    super.initState();
    _step = ref.read(rescueSessionProvider).isRequested(widget.type)
        ? _SheetStep.confirmation
        : _SheetStep.activate;
  }

  void _activate() => setState(() => _step = _SheetStep.details);

  void _submitRequest() {
    ref.read(rescueSessionProvider.notifier).submitEmergency(widget.type);
    setState(() => _step = _SheetStep.confirmation);
  }

  void _openMap() {
    Navigator.of(context).pop();
    widget.onViewMap?.call();
  }

  void _cancelSos() {
    ref.read(rescueSessionProvider.notifier).cancelEmergency(widget.type);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD8E0ED),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: switch (_step) {
                _SheetStep.activate => _activationView(),
                _SheetStep.details => _detailsView(),
                _SheetStep.confirmation => _confirmationView(),
              },
            ),
          ],
        ),
      ),
    ),
  );

  Widget _activationView() => KeyedSubtree(
    key: const ValueKey('activate'),
    child: Column(
      children: [
        _Header(details: _details),
        const SizedBox(height: 18),
        _ResponseInformation(details: _details),
        const SizedBox(height: 14),
        const _LocationNotice(),
        const SizedBox(height: 22),
        EmergencyHoldButton(
          label: 'Hold to activate',
          icon: _details.icon,
          color: _details.accent,
          onActivated: _activate,
        ),
      ],
    ),
  );

  Widget _detailsView() => KeyedSubtree(
    key: const ValueKey('details'),
    child: Column(
      children: [
        _Header(
          details: _details,
          titleOverride: '${_details.shortTitle} activated',
          subtitleOverride: 'Add any details before sending the request.',
        ),
        const SizedBox(height: 14),
        const _LocationNotice(),
        const SizedBox(height: 14),
        EmergencyVoiceRecorder(
          prompt: _details.voicePrompt,
          accent: _details.accent,
          onChanged: (recording) => setState(() => _voiceRecording = recording),
        ),
        const SizedBox(height: 20),
        _PrimaryButton(
          label: _details.requestLabel,
          icon: _details.isHelicopter
              ? Icons.phone_in_talk_rounded
              : Icons.send_rounded,
          color: _details.accent,
          onPressed: _submitRequest,
        ),
      ],
    ),
  );

  Widget _confirmationView() {
    final status = ref.watch(rescueSessionProvider).statusFor(widget.type);
    return KeyedSubtree(
      key: const ValueKey('confirmation'),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFF20A366),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 33,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _details.confirmationTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF08613E),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _details.confirmationMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF667085)),
          ),
          const SizedBox(height: 18),
          _ResponseInformation(details: _details),
          const SizedBox(height: 14),
          _EmergencyStepper(status: status, accent: _details.accent),
          if (_voiceRecording != null) ...[
            const SizedBox(height: 14),
            EmergencyVoiceRecorder(
              prompt: 'This recording will be shared with the control room.',
              accent: _details.accent,
              initialRecording: _voiceRecording,
              readOnly: true,
              onChanged: (_) {},
            ),
          ],
          const SizedBox(height: 20),
          _PrimaryButton(
            label: _details.isHelicopter ? 'Track on Map' : 'View on Map',
            icon: Icons.map_outlined,
            color: _details.accent,
            onPressed: _openMap,
          ),
          if (_details.isSos) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _cancelSos,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Cancel SOS'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE84545),
                  side: const BorderSide(color: Color(0xFFE84545)),
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.details,
    this.titleOverride,
    this.subtitleOverride,
  });

  final EmergencyActionDetails details;
  final String? titleOverride;
  final String? subtitleOverride;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: details.accent.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(details.icon, color: details.accent, size: 29),
      ),
      const SizedBox(height: 10),
      Text(
        titleOverride ?? details.title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 4),
      Text(
        subtitleOverride ?? details.subtitle,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF667085)),
      ),
      if (titleOverride == null) ...[
        const SizedBox(height: 8),
        Text(
          details.description,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
        ),
      ],
    ],
  );
}

class _LocationNotice extends StatelessWidget {
  const _LocationNotice();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F6FF),
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Row(
      children: [
        Icon(Icons.location_on_rounded, color: Color(0xFF3178E6)),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your location will be shared automatically.',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                'Sector B · Uttarkashi, Uttarakhand',
                style: TextStyle(color: Color(0xFF667085), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ResponseInformation extends StatelessWidget {
  const _ResponseInformation({required this.details});
  final EmergencyActionDetails details;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFFF4F7FC),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        _InfoLine(
          icon: Icons.place_outlined,
          label: details.unitLabel,
          value: details.unitName,
        ),
        const SizedBox(height: 11),
        _InfoLine(
          icon: Icons.route_outlined,
          label: 'Distance',
          value: details.distance,
        ),
        const SizedBox(height: 11),
        _InfoLine(
          icon: Icons.schedule_rounded,
          label: 'Estimated Arrival',
          value: details.eta,
        ),
        if (details.landingZone != null) ...[
          const SizedBox(height: 11),
          _InfoLine(
            icon: Icons.flight_rounded,
            label: 'Suggested Landing Zone',
            value: details.landingZone!,
          ),
        ],
      ],
    ),
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 21, color: const Color(0xFF4B5D7D)),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    ],
  );
}

class _EmergencyStepper extends StatelessWidget {
  const _EmergencyStepper({required this.status, required this.accent});
  final EmergencyRequestStatus status;
  final Color accent;

  int get _activeStep => switch (status) {
    EmergencyRequestStatus.idle || EmergencyRequestStatus.requested => 0,
    EmergencyRequestStatus.dispatched => 1,
    EmergencyRequestStatus.enRoute => 2,
  };

  @override
  Widget build(BuildContext context) {
    const labels = ['Requested', 'Dispatched', 'En Route', 'Arriving'];
    return Row(
      children: List.generate(labels.length, (index) {
        final active = index <= _activeStep;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 3,
                      color: index == 0
                          ? Colors.transparent
                          : active
                          ? accent
                          : const Color(0xFFDCE4F0),
                    ),
                  ),
                  Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: active ? accent : const Color(0xFFDCE4F0),
                      shape: BoxShape.circle,
                    ),
                    child: active
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      height: 3,
                      color: index == labels.length - 1
                          ? Colors.transparent
                          : index < _activeStep
                          ? accent
                          : const Color(0xFFDCE4F0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: active
                      ? const Color(0xFF14223B)
                      : const Color(0xFF667085),
                  fontSize: 9,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
  );
}
