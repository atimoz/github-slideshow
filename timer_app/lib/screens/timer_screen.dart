import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_timer.dart';
import '../widgets/ghost_button.dart';

// ─────────────────────────────────────────────
//  TimerScreen — Central swipe screen
// ─────────────────────────────────────────────
class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        final isRunning = timer.status == TimerStatus.running;
        final isPaused = timer.status == TimerStatus.paused;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Stack(
              children: [
                // ── Ambient background glow ──
                Positioned(
                  top: -80,
                  left: MediaQuery.of(context).size.width / 2 - 150,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accent.withOpacity(
                              isRunning ? 0.12 : 0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Column(
                  children: [
                    // ── Top bar ─────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Label(
                            label: 'Today',
                            value: _format(timer.todayTotal),
                          )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms),
                          _StatusChip(status: timer.status)
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 400.ms),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // ── Circular timer ───────
                    CircularTimer(
                      progress: timer.dailyProgress,
                      size: 280,
                      strokeWidth: 5,
                      child: _TimerFace(
                        elapsed: timer.elapsed,
                        progress: timer.dailyProgress,
                        format: _format,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(
                            begin: const Offset(0.88, 0.88),
                            duration: 600.ms,
                            curve: Curves.easeOutBack),

                    const SizedBox(height: 14),

                    // ── Goal progress bar ────
                    _GoalBar(progress: timer.dailyProgress)
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms)
                        .slideY(begin: 0.2, duration: 400.ms),

                    const Spacer(flex: 2),

                    // ── Controls ─────────────
                    _Controls(
                      isRunning: isRunning,
                      isPaused: isPaused,
                      onPlay: timer.start,
                      onPause: timer.pause,
                      onStop: timer.stop,
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms)
                        .slideY(begin: 0.3, duration: 500.ms),

                    const SizedBox(height: 48),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  _TimerFace — digit display inside ring
// ─────────────────────────────────────────────
class _TimerFace extends StatelessWidget {
  const _TimerFace({
    required this.elapsed,
    required this.progress,
    required this.format,
  });

  final Duration elapsed;
  final double progress;
  final String Function(Duration) format;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toInt();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Time digits
        Text(
          format(elapsed),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 52,
            fontWeight: FontWeight.w200,
            letterSpacing: -3,
            color: AppColors.textPrimary,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        // Goal percentage
        Text(
          '$pct% of goal',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  _GoalBar — thin linear progress beneath ring
// ─────────────────────────────────────────────
class _GoalBar extends StatelessWidget {
  const _GoalBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily goal',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5)),
              Text('${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 3,
                backgroundColor: AppColors.stroke,
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _Controls
// ─────────────────────────────────────────────
class _Controls extends StatelessWidget {
  const _Controls({
    required this.isRunning,
    required this.isPaused,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
  });

  final bool isRunning, isPaused;
  final VoidCallback onPlay, onPause, onStop;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stop — only visible when active
        AnimatedOpacity(
          opacity: isRunning || isPaused ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: GhostButton(
            icon: Icons.stop_rounded,
            onTap: isRunning || isPaused ? onStop : () {},
            color: AppColors.destructive.withOpacity(0.9),
          ),
        ),

        const SizedBox(width: 24),

        // Play / Pause — always visible, large
        _PlayPauseButton(
          isRunning: isRunning,
          onPlay: onPlay,
          onPause: onPause,
        ),

        const SizedBox(width: 24),

        // Spacer ghost (keeps layout centred)
        AnimatedOpacity(
          opacity: 0,
          duration: Duration.zero,
          child: GhostButton(icon: Icons.stop_rounded, onTap: () {}),
        ),
      ],
    );
  }
}

class _PlayPauseButton extends StatefulWidget {
  const _PlayPauseButton({
    required this.isRunning,
    required this.onPlay,
    required this.onPause,
  });
  final bool isRunning;
  final VoidCallback onPlay, onPause;

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.isRunning ? widget.onPause() : widget.onPlay();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _ctrl.value * 0.08,
          child: child,
        ),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.timerGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              widget.isRunning
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              key: ValueKey(widget.isRunning),
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────
class _Label extends StatelessWidget {
  const _Label({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final TimerStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TimerStatus.running => ('● RUNNING', AppColors.success),
      TimerStatus.paused => ('⏸ PAUSED', AppColors.warning),
      TimerStatus.idle => ('READY', AppColors.textTertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2)),
    );
  }
}
