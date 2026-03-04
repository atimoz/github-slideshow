import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
//  AnalyticsScreen — Left swipe screen
// ─────────────────────────────────────────────
enum _View { day, week, month }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  _View _view = _View.week;

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
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
                        const Text('Analytics',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5))
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: -0.1, duration: 400.ms),
                        const SizedBox(height: 4),
                        const Text('Your focus journey',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary))
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 400.ms),
                      ],
                    ),
                  ),
                ),

                // ── Summary cards ────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Today',
                            value: _fmtHours(timer.todayTotal),
                            sub: '${(timer.dailyProgress * 100).toInt()}% of daily goal',
                            color: AppColors.accent,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'This week',
                            value: _fmtHours(timer.weekTotal),
                            sub: '${(timer.weeklyProgress * 100).toInt()}% of weekly goal',
                            color: AppColors.accentSoft,
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── View switcher ────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: _ViewSwitcher(
                      selected: _view,
                      onChanged: (v) => setState(() => _view = v),
                    ).animate().fadeIn(delay: 350.ms),
                  ),
                ),

                // ── Chart ────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: _ChartCard(view: _view, timer: timer)
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.15, duration: 500.ms),
                  ),
                ),

                // ── Weekly goal bar ──────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: _GoalCard(
                      label: 'Weekly goal',
                      progress: timer.weeklyProgress,
                      current: timer.weekTotal,
                      goal: timer.weeklyGoal,
                    ).animate().fadeIn(delay: 500.ms),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmtHours(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }
}

// ─────────────────────────────────────────────
//  _ChartCard
// ─────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.view, required this.timer});
  final _View view;
  final TimerProvider timer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            view == _View.day
                ? 'Hours by time of day'
                : view == _View.week
                    ? 'Hours this week'
                    : 'Hours this month',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 180, child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildChart() {
    switch (view) {
      case _View.day:
        return _buildLineChart(_daySpots());
      case _View.week:
        return _buildBarChart(_weekBars());
      case _View.month:
        return _buildLineChart(_monthSpots());
    }
  }

  // Day view — hourly line chart
  List<FlSpot> _daySpots() {
    final breakdown = timer.hourlyBreakdown;
    return List.generate(24, (i) {
      return FlSpot(i.toDouble(), breakdown[i].inMinutes / 60.0);
    });
  }

  // Week view — bar chart per day
  List<BarChartGroupData> _weekBars() {
    final breakdown = timer.weeklyBreakdown;
    return List.generate(7, (i) {
      final val = breakdown[i].inMinutes / 60.0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: val,
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: AppColors.timerGradient,
            ),
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 10,
              color: AppColors.surfaceAlt,
            ),
          ),
        ],
      );
    });
  }

  // Month view — mocked 30-day line
  List<FlSpot> _monthSpots() {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    for (var i = 0; i < 30; i++) {
      final day = DateTime(now.year, now.month, 1).add(Duration(days: i));
      final total = timer.sessions.where((s) {
        final d = s.startTime;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      }).fold(Duration.zero, (acc, s) => acc + s.duration);
      spots.add(FlSpot(i.toDouble(), total.inMinutes / 60.0));
    }
    return spots;
  }

  Widget _buildLineChart(List<FlSpot> spots) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final labels = view == _View.day
                    ? ['0', '6', '12', '18', '23']
                    : List.generate(30, (i) => (i + 1).toString());
                final step = view == _View.day ? 6.0 : 7.0;
                if (value % step == 0) {
                  return Text(value.toInt().toString(),
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textTertiary));
                }
                return const SizedBox.shrink();
              },
              reservedSize: 22,
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.accent,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.chartGradient,
              ),
            ),
          ),
        ],
        minY: 0,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surface,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${s.y.toStringAsFixed(1)}h',
                      const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<BarChartGroupData> groups) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  days[value.toInt()],
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textTertiary),
                ),
              ),
              reservedSize: 24,
            ),
          ),
        ),
        barGroups: groups,
        maxY: 10,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.surface,
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              '${rod.toY.toStringAsFixed(1)}h',
              const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _ViewSwitcher
// ─────────────────────────────────────────────
class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({required this.selected, required this.onChanged});
  final _View selected;
  final ValueChanged<_View> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: _View.values
            .map((v) => Expanded(child: _Tab(v, selected, onChanged)))
            .toList(),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(this.view, this.selected, this.onChanged);
  final _View view, selected;
  final ValueChanged<_View> onChanged;

  String get label => switch (view) {
        _View.day => 'Day',
        _View.week => 'Week',
        _View.month => 'Month',
      };

  @override
  Widget build(BuildContext context) {
    final isActive = view == selected;
    return GestureDetector(
      onTap: () => onChanged(view),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
                isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _SummaryCard
// ─────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });
  final String label, value, sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(sub,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _GoalCard
// ─────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.label,
    required this.progress,
    required this.current,
    required this.goal,
  });
  final String label;
  final double progress;
  final Duration current, goal;

  String _fmt(Duration d) => '${d.inHours}h ${d.inMinutes.remainder(60)}m';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: AppColors.surfaceAlt,
                valueColor: AlwaysStoppedAnimation(
                  progress >= 1.0 ? AppColors.success : AppColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text('${_fmt(current)} / ${_fmt(goal)}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
