import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceRecording {
  const VoiceRecording({required this.path, required this.duration});

  final String path;
  final Duration duration;
}

class EmergencyVoiceRecorder extends StatefulWidget {
  const EmergencyVoiceRecorder({
    super.key,
    required this.prompt,
    required this.accent,
    required this.onChanged,
    this.initialRecording,
    this.readOnly = false,
  });

  final String prompt;
  final Color accent;
  final ValueChanged<VoiceRecording?> onChanged;
  final VoiceRecording? initialRecording;
  final bool readOnly;

  @override
  State<EmergencyVoiceRecorder> createState() => _EmergencyVoiceRecorderState();
}

class _EmergencyVoiceRecorderState extends State<EmergencyVoiceRecorder> {
  static const _maximumDuration = Duration(seconds: 30);
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final Stopwatch _stopwatch = Stopwatch();

  Timer? _ticker;
  StreamSubscription<PlayerState>? _playerSubscription;
  VoiceRecording? _recording;
  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _recording = widget.initialRecording;
    _playerSubscription = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      final isPlaying =
          state.playing && state.processingState != ProcessingState.completed;
      if (_isPlaying != isPlaying) setState(() => _isPlaying = isPlaying);
    });
  }

  void _message(String text) {
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _startRecording() async {
    if (widget.readOnly || _isRecording) return;
    try {
      if (!await _recorder.hasPermission()) {
        _message(
          'Microphone permission is required to record a voice message.',
        );
        return;
      }
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/resq_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _elapsed = Duration.zero;
        _stopwatch
          ..reset()
          ..start();
      });
      _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (!mounted) return;
        final elapsed = _stopwatch.elapsed;
        if (elapsed >= _maximumDuration) {
          _stopRecording();
        } else {
          setState(() => _elapsed = elapsed);
        }
      });
    } catch (_) {
      _message(
        'Unable to start recording. You can still send the request without audio.',
      );
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    _ticker?.cancel();
    _stopwatch.stop();
    try {
      final path = await _recorder.stop();
      if (!mounted) return;
      if (path == null) {
        setState(() => _isRecording = false);
        _message('The voice message could not be saved.');
        return;
      }
      final recording = VoiceRecording(
        path: path,
        duration: _stopwatch.elapsed,
      );
      setState(() {
        _isRecording = false;
        _elapsed = recording.duration;
        _recording = recording;
      });
      widget.onChanged(recording);
    } catch (_) {
      if (mounted) {
        setState(() => _isRecording = false);
        _message('Unable to save the voice message.');
      }
    }
  }

  Future<void> _deleteRecording() async {
    await _player.stop();
    if (_isRecording) {
      _ticker?.cancel();
      await _recorder.cancel();
    }
    final recording = _recording;
    if (recording != null) {
      try {
        final file = File(recording.path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // The temporary file may already have been cleared by the operating system.
      }
    }
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _isPlaying = false;
      _recording = null;
      _elapsed = Duration.zero;
      _stopwatch.reset();
    });
    widget.onChanged(null);
  }

  Future<void> _togglePlayback() async {
    final recording = _recording;
    if (recording == null || _isRecording) return;
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.setFilePath(recording.path);
        _player.play();
      }
    } catch (_) {
      _message('Unable to play this voice message.');
    }
  }

  String _timeLabel(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _playerSubscription?.cancel();
    _player.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasRecording = _recording != null;
    final displayDuration = hasRecording ? _recording!.duration : _elapsed;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasRecording && widget.readOnly
                ? 'Voice message attached'
                : 'Add a voice message',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            widget.prompt,
            style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (_isRecording)
            _recordingView(displayDuration)
          else if (hasRecording)
            _recordedView(displayDuration)
          else
            _idleView(),
        ],
      ),
    );
  }

  Widget _idleView() => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: widget.accent.withValues(alpha: .13),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.mic_none_rounded, color: widget.accent),
      ),
      const SizedBox(width: 11),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tap to record',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              '00:00 · up to 30 seconds',
              style: TextStyle(color: Color(0xFF667085), fontSize: 12),
            ),
          ],
        ),
      ),
      if (!widget.readOnly)
        IconButton.filled(
          onPressed: _startRecording,
          icon: const Icon(Icons.mic_rounded),
          style: IconButton.styleFrom(backgroundColor: widget.accent),
        ),
    ],
  );

  Widget _recordingView(Duration duration) => Row(
    children: [
      Icon(Icons.circle, color: Colors.red.shade500, size: 12),
      const SizedBox(width: 8),
      const Expanded(
        child: Text(
          'Recording...',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      Text(
        _timeLabel(duration),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      const SizedBox(width: 8),
      IconButton.filled(
        onPressed: _stopRecording,
        icon: const Icon(Icons.stop_rounded),
        style: IconButton.styleFrom(backgroundColor: Colors.red.shade500),
      ),
    ],
  );

  Widget _recordedView(Duration duration) => Row(
    children: [
      IconButton.filled(
        onPressed: _togglePlayback,
        icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
        style: IconButton.styleFrom(backgroundColor: widget.accent),
      ),
      const SizedBox(width: 8),
      Expanded(child: _Waveform(color: widget.accent)),
      const SizedBox(width: 8),
      Text(
        _timeLabel(duration),
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
      if (!widget.readOnly) ...[
        const SizedBox(width: 2),
        IconButton(
          onPressed: _deleteRecording,
          tooltip: 'Delete voice message',
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    ],
  );
}

class _Waveform extends StatelessWidget {
  const _Waveform({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 30,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
        20,
        (index) => Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              height: 7 + ((index * 13) % 20).toDouble(),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .72),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
