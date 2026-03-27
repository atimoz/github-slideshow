import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
//  GhostButton — Apple-style haptic icon button
// ─────────────────────────────────────────────
class GhostButton extends StatefulWidget {
  const GhostButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 60,
    this.iconSize = 22,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color? color;

  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  void _onTapDown(_) => _ctrl.reverse();
  void _onTapUp(_) {
    _ctrl.forward();
    HapticFeedback.lightImpact();
    widget.onTap();
  }
  void _onTapCancel() => _ctrl.forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.stroke, width: 1),
          ),
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: widget.color ?? AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
