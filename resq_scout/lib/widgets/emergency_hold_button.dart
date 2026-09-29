import 'dart:async';

import 'package:flutter/material.dart';

class EmergencyHoldButton extends StatefulWidget {
  const EmergencyHoldButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onActivated,
    this.duration = const Duration(seconds: 2),
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onActivated;
  final Duration duration;

  @override
  State<EmergencyHoldButton> createState() => _EmergencyHoldButtonState();
}

class _EmergencyHoldButtonState extends State<EmergencyHoldButton> {
  Timer? _timer;
  double _progress = 0;
  Duration _elapsed = Duration.zero;
  bool _isHolding = false;
  bool _didActivate = false;

  void _startHold(TapDownDetails details) {
    if (_didActivate || _isHolding) return;
    setState(() {
      _isHolding = true;
      _progress = 0;
      _elapsed = Duration.zero;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 25), (_) {
      if (!mounted) return;
      _elapsed += const Duration(milliseconds: 25);
      final progress = _elapsed.inMilliseconds / widget.duration.inMilliseconds;
      if (progress >= 1) {
        _completeHold();
      } else {
        setState(() => _progress = progress);
      }
    });
  }

  void _cancelHold() {
    if (!_isHolding || _didActivate) return;
    _timer?.cancel();
    setState(() {
      _isHolding = false;
      _progress = 0;
    });
  }

  void _completeHold() {
    _timer?.cancel();
    if (!_isHolding || _didActivate) return;
    setState(() {
      _progress = 1;
      _isHolding = false;
      _didActivate = true;
    });
    widget.onActivated();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _elapsed.inMilliseconds / 1000;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _startHold,
      onTapUp: (_) => _cancelHold(),
      onTapCancel: _cancelHold,
      child: Column(
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 140),
            scale: _isHolding ? .98 : 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 64,
                  width: double.infinity,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 4,
                    color: widget.color,
                    backgroundColor: widget.color.withValues(alpha: .15),
                  ),
                ),
                Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: .26),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _didActivate ? Icons.check_rounded : widget.icon,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        _didActivate ? 'Activated' : widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isHolding
                ? 'Keep holding... ${elapsed.toStringAsFixed(1)}s'
                : 'Hold for 2 seconds',
            style: TextStyle(
              color: _isHolding ? widget.color : const Color(0xFF667085),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
