import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
//  SettingsScreen — Modal sheet
// ─────────────────────────────────────────────
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<TimerProvider>(),
        child: const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.stroke, width: 1),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: const [
                    _SettingsHeader(),
                    SizedBox(height: 28),
                    _GoalSection(),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.stroke),
            ),
            child: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _GoalSection extends StatelessWidget {
  const _GoalSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (_, timer, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Goals',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.2)),
          const SizedBox(height: 14),

          // Daily goal
          _GoalTile(
            label: 'Daily goal',
            sub: 'Focus hours per day',
            current: timer.dailyGoal,
            min: const Duration(hours: 1),
            max: const Duration(hours: 16),
            step: const Duration(minutes: 30),
            onChanged: timer.setDailyGoal,
          ),

          const SizedBox(height: 12),

          // Weekly goal
          _GoalTile(
            label: 'Weekly goal',
            sub: 'Total focus hours per week',
            current: timer.weeklyGoal,
            min: const Duration(hours: 5),
            max: const Duration(hours: 80),
            step: const Duration(hours: 1),
            onChanged: timer.setWeeklyGoal,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _GoalTile — stepper control for time goals
// ─────────────────────────────────────────────
class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.label,
    required this.sub,
    required this.current,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final String label, sub;
  final Duration current, min, max, step;
  final Future<void> Function(Duration) onChanged;

  String _fmt(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inMinutes % 60 == 0) return '${d.inHours}h';
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  }

  void _tap(bool increment) {
    HapticFeedback.selectionClick();
    final next =
        increment ? current + step : current - step;
    if (next >= min && next <= max) onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),

          // Stepper
          Row(
            children: [
              _StepButton(
                icon: CupertinoIcons.minus,
                onTap: () => _tap(false),
                enabled: current > min,
              ),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  _fmt(current),
                  key: ValueKey(current),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StepButton(
                icon: CupertinoIcons.plus,
                onTap: () => _tap(true),
                enabled: current < max,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.accent.withOpacity(0.12)
              : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? AppColors.accent.withOpacity(0.3)
                : AppColors.stroke,
          ),
        ),
        child: Icon(icon,
            size: 14,
            color: enabled
                ? AppColors.accent
                : AppColors.textTertiary),
      ),
    );
  }
}
