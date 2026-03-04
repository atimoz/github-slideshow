import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'analytics_screen.dart';
import 'social_screen.dart';
import 'timer_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
//  HomeShell — swipeable 3-screen shell
//  Layout:  [Analytics] ← [Timer] → [Social]
// ─────────────────────────────────────────────
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _controller = PageController(initialPage: 1);

  static const _screens = [
    AnalyticsScreen(),
    TimerScreen(),
    SocialScreen(),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // ── Main pager ─────────────────────
          PageView(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            children: _screens,
          ),

          // ── Page dots (bottom center) ──────
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: const ExpandingDotsEffect(
                  activeDotColor: AppColors.accent,
                  dotColor: AppColors.textTertiary,
                  dotHeight: 4,
                  dotWidth: 4,
                  expansionFactor: 4,
                  spacing: 5,
                ),
              ),
            ),
          ),

          // ── Settings button (top-right) ────
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            right: 20,
            child: _SettingsButton(
              onTap: () => SettingsScreen.show(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _SettingsButton
// ─────────────────────────────────────────────
class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.stroke, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.tune_rounded,
            size: 16, color: AppColors.textSecondary),
      ),
    );
  }
}
