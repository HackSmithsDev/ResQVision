import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../models/drone.dart';

const _navy = Color(0xFF111B30);
const _muted = AppColors.muted;
const _blue = AppColors.primary;
const _green = Color(0xFF149C63);
const _amber = AppColors.warning;
const _red = AppColors.danger;

class DroneStatusSummary extends StatelessWidget {
  const DroneStatusSummary({super.key, required this.drones});
  final List<Drone> drones;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final counts = <DroneStatus, int>{
        for (final status in DroneStatus.values)
          status: drones.where((drone) => drone.status == status).length,
      };
      final compact = constraints.maxWidth < 520;
      return Row(
        children: [
          _StatusCount(
            icon: Icons.flight_rounded,
            label: 'Active',
            count: counts[DroneStatus.active]!,
            color: _green,
            compact: compact,
          ),
          SizedBox(width: compact ? 7 : 12),
          _StatusCount(
            icon: Icons.bolt_rounded,
            label: 'Charging',
            count: counts[DroneStatus.charging]!,
            color: _amber,
            compact: compact,
          ),
          SizedBox(width: compact ? 7 : 12),
          _StatusCount(
            icon: Icons.portable_wifi_off_rounded,
            label: 'Offline',
            count: counts[DroneStatus.offline]!,
            color: _muted,
            compact: compact,
          ),
        ],
      );
    },
  );
}

class _StatusCount extends StatelessWidget {
  const _StatusCount({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.compact,
  });
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: compact ? 68 : 76,
      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D14223B),
            blurRadius: 13,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: compact
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: _navy,
                      ),
                    ),
                  ],
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 27),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: _navy,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    ),
  );
}

class DroneSearchBar extends StatelessWidget {
  const DroneSearchBar({
    super.key,
    required this.onChanged,
    required this.selectedFilter,
    required this.onFilterSelected,
  });
  final ValueChanged<String> onChanged;
  final DroneStatus? selectedFilter;
  final ValueChanged<DroneStatus?> onFilterSelected;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search drones, location, or status...',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE7EDF6)),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      PopupMenuButton<String>(
        tooltip: 'Filter drones',
        onSelected: (value) => onFilterSelected(
          value == 'all' ? null : DroneStatus.values.byName(value),
        ),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'all', child: Text('All drones')),
          ...DroneStatus.values.map(
            (status) => PopupMenuItem(
              value: status.name,
              child: Text(_statusLabel(status)),
            ),
          ),
        ],
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: selectedFilter == null
                ? Colors.white
                : const Color(0xFFE8F1FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE7EDF6)),
          ),
          child: const Icon(Icons.tune_rounded, color: _navy),
        ),
      ),
    ],
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: _navy,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        '$count ${count == 1 ? 'drone' : 'drones'}',
        style: const TextStyle(color: _muted, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

/// Compact, non-expandable drone overview. Used by [ExpandableDroneCard].
class DroneCard extends StatelessWidget {
  const DroneCard({
    super.key,
    required this.drone,
    required this.onTap,
    this.trailing,
  });
  final Drone drone;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 520;
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: compact ? _compactLayout() : _wideLayout(),
        ),
      );
    },
  );

  Widget _wideLayout() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _DroneThumbnail(drone: drone),
      const SizedBox(width: 15),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _droneName()),
                _DroneStatusPill(status: drone.status),
              ],
            ),
            const SizedBox(height: 6),
            _location(),
            const SizedBox(height: 13),
            _metrics(),
            const SizedBox(height: 8),
            _lastUpdated(),
          ],
        ),
      ),
      if (trailing != null) ...[const SizedBox(width: 8), trailing!],
    ],
  );

  Widget _compactLayout() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DroneThumbnail(drone: drone, compact: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _droneName(),
                const SizedBox(height: 6),
                _DroneStatusPill(status: drone.status),
                const SizedBox(height: 7),
                _location(),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
        ],
      ),
      const SizedBox(height: 13),
      _metrics(),
      const SizedBox(height: 8),
      _lastUpdated(),
    ],
  );

  Widget _droneName() => Text(
    drone.name,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w900,
      color: _navy,
    ),
  );

  Widget _location() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.location_on_rounded, size: 16, color: _muted),
      const SizedBox(width: 3),
      Flexible(
        child: Text(
          drone.location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _muted, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );

  Widget _metrics() => Wrap(
    spacing: 20,
    runSpacing: 8,
    children: [
      _Metric(
        icon: Icons.battery_full_rounded,
        value: '${drone.batteryPercentage}%',
        label: 'Battery',
        color: _batteryColor(drone.batteryPercentage),
      ),
      _Metric(
        icon: Icons.height_rounded,
        value: _meters(drone.altitudeMeters),
        label: 'Altitude',
      ),
      _Metric(
        icon: Icons.speed_rounded,
        value: _speed(drone.speedKmh),
        label: 'Speed',
      ),
    ],
  );

  Widget _lastUpdated() => Text(
    _updatedLabel(drone.lastUpdated),
    style: const TextStyle(fontSize: 11, color: _muted),
  );
}

class ExpandableDroneCard extends StatelessWidget {
  const ExpandableDroneCard({
    super.key,
    required this.drone,
    required this.isExpanded,
    required this.onToggle,
    required this.onLiveFootage,
    required this.onManualControl,
  });
  final Drone drone;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onLiveFootage;
  final VoidCallback onManualControl;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D14223B),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      children: [
        DroneCard(
          drone: drone,
          onTap: onToggle,
          trailing: Icon(
            isExpanded
                ? Icons.expand_less_rounded
                : Icons.chevron_right_rounded,
            color: _navy,
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: LayoutBuilder(
            builder: (context, constraints) {
              final liveFootageButton = DroneActionButton(
                icon: Icons.videocam_rounded,
                label: 'Live Footage',
                onPressed: onLiveFootage,
              );
              final manualControlButton = DroneActionButton(
                icon: Icons.gamepad_rounded,
                label: 'Manual Control',
                onPressed: onManualControl,
                filled: true,
              );
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: constraints.maxWidth < 520
                    ? Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: liveFootageButton,
                          ),
                          const SizedBox(height: 9),
                          SizedBox(
                            width: double.infinity,
                            child: manualControlButton,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: liveFootageButton),
                          const SizedBox(width: 10),
                          Expanded(child: manualControlButton),
                        ],
                      ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class DroneActionButton extends StatelessWidget {
  const DroneActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 19),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: filled ? Colors.white : _blue,
      backgroundColor: filled ? _blue : Colors.white,
      side: BorderSide(color: _blue.withValues(alpha: .45)),
      padding: const EdgeInsets.symmetric(vertical: 13),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    ),
  );
}

class DroneVideoView extends StatelessWidget {
  const DroneVideoView({super.key, required this.drone, this.message});
  final Drone drone;
  final String? message;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (drone.thumbnailUrl != null)
        Image.asset(drone.thumbnailUrl!, fit: BoxFit.cover)
      else
        const ColoredBox(color: _navy),
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: .48),
              Colors.black.withValues(alpha: .06),
              Colors.black.withValues(alpha: .52),
            ],
          ),
        ),
      ),
      Center(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xBB111B30),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                drone.videoAvailable
                    ? Icons.play_circle_outline_rounded
                    : Icons.videocam_off_rounded,
                color: Colors.white,
                size: 42,
              ),
              const SizedBox(height: 8),
              Text(
                message ??
                    (drone.videoAvailable
                        ? 'Live video preview'
                        : 'Video stream unavailable'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ready for a drone video stream',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class TelemetryOverlay extends StatelessWidget {
  const TelemetryOverlay({super.key, required this.drone});
  final Drone drone;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xD9111B30),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white24),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          drone.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${_statusLabel(drone.status)} · ${drone.location}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 11),
        Wrap(
          spacing: 15,
          runSpacing: 8,
          children: [
            _DarkMetric(
              icon: Icons.battery_full_rounded,
              text: '${drone.batteryPercentage}%',
            ),
            _DarkMetric(
              icon: Icons.height_rounded,
              text: _meters(drone.altitudeMeters),
            ),
            _DarkMetric(
              icon: Icons.speed_rounded,
              text: _speed(drone.speedKmh),
            ),
            _DarkMetric(
              icon: Icons.network_cell_rounded,
              text: drone.signalDbm == null ? '—' : '${drone.signalDbm} dBm',
            ),
          ],
        ),
      ],
    ),
  );
}

class TelemetryBar extends StatelessWidget {
  const TelemetryBar({super.key, required this.drone});
  final Drone drone;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
    decoration: BoxDecoration(
      color: const Color(0xDE111B30),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.white24),
    ),
    child: Wrap(
      spacing: 25,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        _DarkMetric(
          icon: Icons.battery_full_rounded,
          text: '${drone.batteryPercentage}%',
        ),
        _DarkMetric(
          icon: Icons.height_rounded,
          text: _meters(drone.altitudeMeters),
        ),
        _DarkMetric(icon: Icons.speed_rounded, text: _speed(drone.speedKmh)),
        _DarkMetric(
          icon: Icons.network_cell_rounded,
          text: drone.signalDbm == null ? '—' : '${drone.signalDbm} dBm',
        ),
      ],
    ),
  );
}

class _DarkMetric extends StatelessWidget {
  const _DarkMetric({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: const Color(0xFF78DDF2), size: 18),
      const SizedBox(width: 5),
      Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class VirtualJoystick extends StatefulWidget {
  const VirtualJoystick({
    super.key,
    required this.label,
    required this.icon,
    this.onChanged,
  });
  final String label;
  final IconData icon;
  final ValueChanged<Offset>? onChanged;

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _position = Offset.zero;

  void _update(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .28;
    final candidate = localPosition - center;
    final distance = candidate.distance;
    final next = distance > radius ? candidate / distance * radius : candidate;
    setState(() => _position = next);
    widget.onChanged?.call(Offset(next.dx / radius, next.dy / radius));
  }

  void _release() {
    setState(() => _position = Offset.zero);
    widget.onChanged?.call(Offset.zero);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = Size.square(
        math.min(constraints.maxWidth, constraints.maxHeight),
      );
      return SizedBox(
        width: size.width,
        height: size.height,
        child: GestureDetector(
          onPanDown: (details) => _update(details.localPosition, size),
          onPanUpdate: (details) => _update(details.localPosition, size),
          onPanEnd: (_) => _release(),
          onPanCancel: _release,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xC4111B30),
              border: Border.all(color: const Color(0xFF5B6B84), width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Transform.translate(
                  offset: _position,
                  child: Container(
                    width: size.width * .38,
                    height: size.width * .38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2878E6),
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: size.width * .18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class ControlButton extends StatelessWidget {
  const ControlButton({
    super.key,
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
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: FilledButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
    ),
  );
}

class CameraControlButton extends StatelessWidget {
  const CameraControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: const Color(0xDE111B30),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    ),
  );
}

class _DroneThumbnail extends StatelessWidget {
  const _DroneThumbnail({required this.drone, this.compact = false});
  final Drone drone;
  final bool compact;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: SizedBox(
      width: compact ? 112 : 155,
      height: compact ? 104 : 108,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (drone.thumbnailUrl != null)
            Image.asset(drone.thumbnailUrl!, fit: BoxFit.cover)
          else
            const ColoredBox(color: _navy),
          if (drone.videoAvailable)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xD9111B30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Color(0xFFFF4949), size: 9),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _DroneStatusPill extends StatelessWidget {
  const _DroneStatusPill({required this.status});
  final DroneStatus status;
  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == DroneStatus.active
                ? Icons.circle
                : status == DroneStatus.charging
                ? Icons.bolt_rounded
                : Icons.portable_wifi_off_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            _statusLabel(status),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
    this.color = _blue,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 5),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(color: _navy, fontWeight: FontWeight.w900),
          ),
          Text(label, style: const TextStyle(color: _muted, fontSize: 10)),
        ],
      ),
    ],
  );
}

Color _statusColor(DroneStatus status) => switch (status) {
  DroneStatus.active => _green,
  DroneStatus.charging => _amber,
  DroneStatus.offline => _muted,
};
Color _batteryColor(int battery) => battery > 50
    ? _green
    : battery > 20
    ? _amber
    : _red;
String _statusLabel(DroneStatus status) => switch (status) {
  DroneStatus.active => 'Online',
  DroneStatus.charging => 'Charging',
  DroneStatus.offline => 'Offline',
};
String _meters(double? value) => value == null
    ? '—'
    : '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)} m';
String _speed(double? value) => value == null
    ? '—'
    : '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)} km/h';
String _updatedLabel(DateTime updatedAt) {
  final age = DateTime.now().difference(updatedAt);
  if (age.inSeconds < 60) return 'Last updated ${age.inSeconds}s ago';
  return 'Last updated ${age.inMinutes} min ago';
}
