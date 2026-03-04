import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
//  SocialScreen — Right swipe, Leaderboard
// ─────────────────────────────────────────────

// Placeholder data model for future multiplayer
class _LeaderboardEntry {
  const _LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.initials,
    required this.weekHours,
    required this.avatarColor,
    this.isMe = false,
  });
  final int rank;
  final String name, initials;
  final double weekHours;
  final Color avatarColor;
  final bool isMe;
}

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        final myHours = timer.weekTotal.inMinutes / 60.0;

        // Build leaderboard — "You" slot + ghost entries
        final entries = _buildEntries(myHours);

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ──────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Leaderboard',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5))
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.1),
                        const SizedBox(height: 4),
                        const Text('This week · Focus hours',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary))
                            .animate()
                            .fadeIn(delay: 100.ms),
                      ],
                    ),
                  ),
                ),

                // ── Podium (top 3) ───────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: _Podium(entries: entries.take(3).toList())
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 500.ms)
                        .slideY(begin: 0.1),
                  ),
                ),

                // ── Full list ────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  sliver: SliverList.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) => _LeaderRow(
                      entry: entries[i],
                      maxHours: entries.first.weekHours,
                    )
                        .animate()
                        .fadeIn(
                            delay: Duration(milliseconds: 300 + i * 60),
                            duration: 400.ms)
                        .slideX(begin: 0.06),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_LeaderboardEntry> _buildEntries(double myHours) {
    // Placeholder ghost users — ranked above/below based on real score
    final ghosts = [
      _LeaderboardEntry(
          rank: 0,
          name: 'Alex M.',
          initials: 'AM',
          weekHours: 42.5,
          avatarColor: const Color(0xFF5E5CE6)),
      _LeaderboardEntry(
          rank: 0,
          name: 'Sofia R.',
          initials: 'SR',
          weekHours: 38.2,
          avatarColor: const Color(0xFFFF6B6B)),
      _LeaderboardEntry(
          rank: 0,
          name: 'You',
          initials: 'ME',
          weekHours: myHours,
          avatarColor: AppColors.accent,
          isMe: true),
      _LeaderboardEntry(
          rank: 0,
          name: 'Lucas T.',
          initials: 'LT',
          weekHours: 29.0,
          avatarColor: const Color(0xFF30D158)),
      _LeaderboardEntry(
          rank: 0,
          name: 'Emma K.',
          initials: 'EK',
          weekHours: 21.5,
          avatarColor: const Color(0xFFFF9F0A)),
    ];

    // Sort descending, assign ranks
    final sorted = [...ghosts]
      ..sort((a, b) => b.weekHours.compareTo(a.weekHours));
    return sorted
        .asMap()
        .entries
        .map((e) => _LeaderboardEntry(
              rank: e.key + 1,
              name: e.value.name,
              initials: e.value.initials,
              weekHours: e.value.weekHours,
              avatarColor: e.value.avatarColor,
              isMe: e.value.isMe,
            ))
        .toList();
  }
}

// ─────────────────────────────────────────────
//  _Podium — visual podium for top 3
// ─────────────────────────────────────────────
class _Podium extends StatelessWidget {
  const _Podium({required this.entries});
  final List<_LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.length < 3) return const SizedBox.shrink();
    final first = entries[0];
    final second = entries[1];
    final third = entries[2];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd
          _PodiumItem(entry: second, height: 72),
          // 1st
          _PodiumItem(entry: first, height: 96, crownVisible: true),
          // 3rd
          _PodiumItem(entry: third, height: 56),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.entry,
    required this.height,
    this.crownVisible = false,
  });
  final _LeaderboardEntry entry;
  final double height;
  final bool crownVisible;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (crownVisible)
          const Text('👑', style: TextStyle(fontSize: 18))
        else
          const SizedBox(height: 26),
        const SizedBox(height: 4),
        // Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: entry.avatarColor.withOpacity(0.15),
            border: Border.all(
                color: entry.isMe
                    ? AppColors.accent
                    : entry.avatarColor.withOpacity(0.4),
                width: entry.isMe ? 2 : 1.5),
          ),
          child: Center(
            child: Text(entry.initials,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: entry.avatarColor)),
          ),
        ),
        const SizedBox(height: 8),
        Text(entry.name.split(' ').first,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text('${entry.weekHours.toStringAsFixed(1)}h',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: entry.avatarColor)),
        const SizedBox(height: 10),
        // Podium block
        Container(
          width: 68,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                entry.avatarColor.withOpacity(0.3),
                entry.avatarColor.withOpacity(0.08),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: entry.avatarColor.withOpacity(0.2)),
          ),
          child: Center(
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: entry.avatarColor.withOpacity(0.7)),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  _LeaderRow — full list row
// ─────────────────────────────────────────────
class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.entry, required this.maxHours});
  final _LeaderboardEntry entry;
  final double maxHours;

  @override
  Widget build(BuildContext context) {
    final progress = maxHours > 0 ? entry.weekHours / maxHours : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: entry.isMe
            ? AppColors.accentGlow
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.isMe ? AppColors.accent.withOpacity(0.4) : AppColors.stroke,
          width: entry.isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: entry.rank <= 3
                      ? entry.avatarColor
                      : AppColors.textTertiary),
            ),
          ),

          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.avatarColor.withOpacity(0.15),
              border: Border.all(
                  color: entry.avatarColor.withOpacity(0.3), width: 1.5),
            ),
            child: Center(
              child: Text(entry.initials,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: entry.avatarColor)),
            ),
          ),

          const SizedBox(width: 12),

          // Name + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.name + (entry.isMe ? ' (You)' : ''),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: entry.isMe
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: entry.isMe
                              ? AppColors.textPrimary
                              : AppColors.textSecondary),
                    ),
                    Text(
                      '${entry.weekHours.toStringAsFixed(1)}h',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: entry.avatarColor),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      minHeight: 3,
                      backgroundColor: AppColors.surfaceAlt,
                      valueColor:
                          AlwaysStoppedAnimation(entry.avatarColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
