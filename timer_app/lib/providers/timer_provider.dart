import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/work_session.dart';

// ─────────────────────────────────────────────
//  TimerProvider — single source of truth for
//  all timer state & persisted sessions.
// ─────────────────────────────────────────────
enum TimerStatus { idle, running, paused }

class TimerProvider extends ChangeNotifier {
  // ── Public state ───────────────────────────
  TimerStatus status = TimerStatus.idle;
  Duration elapsed = Duration.zero;
  Duration dailyGoal = const Duration(hours: 8);
  Duration weeklyGoal = const Duration(hours: 40);
  List<WorkSession> sessions = [];

  // ── Private ───────────────────────────────
  Timer? _ticker;
  DateTime? _sessionStart;
  final _uuid = const Uuid();

  // ─────────────────────────────────────────
  //  Initialisation — load from persistence
  // ─────────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Goals
    final dailySecs = prefs.getInt('dailyGoalSeconds') ?? 28800; // 8 h
    final weeklySecs = prefs.getInt('weeklyGoalSeconds') ?? 144000; // 40 h
    dailyGoal = Duration(seconds: dailySecs);
    weeklyGoal = Duration(seconds: weeklySecs);

    // Sessions
    final raw = prefs.getStringList('sessions') ?? [];
    sessions = raw
        .map((e) => WorkSession.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();

    notifyListeners();
  }

  // ─────────────────────────────────────────
  //  Controls
  // ─────────────────────────────────────────
  void start() {
    if (status == TimerStatus.running) return;
    status = TimerStatus.running;
    _sessionStart ??= DateTime.now().subtract(elapsed);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    if (status != TimerStatus.running) return;
    _ticker?.cancel();
    status = TimerStatus.paused;
    notifyListeners();
  }

  void stop() {
    _ticker?.cancel();
    if (_sessionStart != null && elapsed.inSeconds > 5) {
      _saveSession(WorkSession(
        id: _uuid.v4(),
        startTime: _sessionStart!,
        endTime: DateTime.now(),
      ));
    }
    elapsed = Duration.zero;
    _sessionStart = null;
    status = TimerStatus.idle;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  //  Goals
  // ─────────────────────────────────────────
  Future<void> setDailyGoal(Duration d) async {
    dailyGoal = d;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoalSeconds', d.inSeconds);
    notifyListeners();
  }

  Future<void> setWeeklyGoal(Duration d) async {
    weeklyGoal = d;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weeklyGoalSeconds', d.inSeconds);
    notifyListeners();
  }

  // ─────────────────────────────────────────
  //  Computed helpers
  // ─────────────────────────────────────────
  Duration get todayTotal {
    final today = DateTime.now();
    final dayTotal = sessions.where((s) {
      final d = s.startTime;
      return d.year == today.year &&
          d.month == today.month &&
          d.day == today.day;
    }).fold(Duration.zero, (acc, s) => acc + s.duration);
    // Add live elapsed if running
    return dayTotal + (status != TimerStatus.idle ? elapsed : Duration.zero);
  }

  Duration get weekTotal {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekTotal = sessions.where((s) {
      return s.startTime.isAfter(weekStart.copyWith(
            hour: 0, minute: 0, second: 0, millisecond: 0));
    }).fold(Duration.zero, (acc, s) => acc + s.duration);
    return weekTotal + (status != TimerStatus.idle ? elapsed : Duration.zero);
  }

  double get dailyProgress =>
      (todayTotal.inSeconds / dailyGoal.inSeconds).clamp(0.0, 1.0);

  double get weeklyProgress =>
      (weekTotal.inSeconds / weeklyGoal.inSeconds).clamp(0.0, 1.0);

  /// Returns a list of 7 daily totals (Mon → Sun) for the current week.
  List<Duration> get weeklyBreakdown {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return sessions.where((s) {
        final d = s.startTime;
        return d.year == day.year &&
            d.month == day.month &&
            d.day == day.day;
      }).fold(Duration.zero, (acc, s) => acc + s.duration);
    });
  }

  /// Returns totals per hour (0-23) for today.
  List<Duration> get hourlyBreakdown {
    final today = DateTime.now();
    return List.generate(24, (h) {
      return sessions.where((s) {
        final d = s.startTime;
        return d.year == today.year &&
            d.month == today.month &&
            d.day == today.day &&
            d.hour == h;
      }).fold(Duration.zero, (acc, s) => acc + s.duration);
    });
  }

  // ─────────────────────────────────────────
  //  Persistence
  // ─────────────────────────────────────────
  Future<void> _saveSession(WorkSession session) async {
    sessions.add(session);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'sessions', sessions.map((s) => jsonEncode(s.toJson())).toList());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
