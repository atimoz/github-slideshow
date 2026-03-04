// ─────────────────────────────────────────────
//  Data model — WorkSession
//  Represents a single focused work interval.
// ─────────────────────────────────────────────

class WorkSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;

  const WorkSession({
    required this.id,
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);

  // ── Serialization ──────────────────────────
  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      };

  factory WorkSession.fromJson(Map<String, dynamic> json) => WorkSession(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
      );
}
