# Focus Timer — Architecture & Design Decisions

## Stack Choice: Flutter ✅

| Criteria | Flutter | React Native | SwiftUI |
|---|---|---|---|
| Cross-platform (iOS + Android) | ✅ | ✅ | ❌ iOS only |
| Custom animations | ⭐⭐⭐ (Skia/Impeller) | ⭐⭐ (JS bridge) | ⭐⭐ |
| 60/120fps guaranteed | ✅ | ⚠️ (JS thread) | ✅ |
| Custom painter (ring) | ✅ `CustomPainter` | ⚠️ SVG / reanimated | ✅ `Canvas` |
| `fl_chart` charts | ✅ | N/A | N/A |
| Single codebase | ✅ | ✅ | ❌ |

**Decision: Flutter** — the Skia/Impeller rendering engine gives us frame-perfect
custom animations (circular ring glow, liquid progress bar) without a JS bridge penalty.

---

## State Architecture

```
TimerProvider (ChangeNotifier)
├── status: TimerStatus { idle | running | paused }
├── elapsed: Duration          ← live tick (1 s)
├── sessions: List<WorkSession> ← persisted in SharedPreferences
├── dailyGoal / weeklyGoal     ← persisted goals
└── computed:
    ├── todayTotal             ← sum of today's sessions + elapsed
    ├── weekTotal
    ├── dailyProgress (0.0–1.0)
    ├── weeklyProgress
    ├── weeklyBreakdown [7]    ← for bar chart
    └── hourlyBreakdown [24]   ← for day line chart
```

### Persistence schema (SharedPreferences)

```json
{
  "dailyGoalSeconds": 28800,
  "weeklyGoalSeconds": 144000,
  "sessions": [
    {
      "id": "uuid-v4",
      "startTime": "2024-01-15T09:00:00.000Z",
      "endTime": "2024-01-15T11:30:00.000Z"
    }
  ]
}
```

> For production: migrate to **SQLite via `sqflite`** or **Drift** ORM
> for efficient date-range queries on large session histories.

---

## Screen Layout

```
PageView (horizontal swipe)
├── [0] AnalyticsScreen   ← swipe left from center
├── [1] TimerScreen       ← default (initialPage: 1)
└── [2] SocialScreen      ← swipe right from center

Overlay (on all screens):
├── SmoothPageIndicator   ← bottom center dots
└── SettingsButton        ← top right → modal sheet
```

---

## Key Widget Tree (Timer Screen)

```
TimerScreen
└── Consumer<TimerProvider>
    └── Scaffold
        └── Stack
            ├── Ambient glow (Container + RadialGradient)
            └── Column
                ├── TopBar (Label + StatusChip)
                ├── CircularTimer ──────────────────────────────┐
                │   ├── TweenAnimationBuilder<double>           │
                │   └── CustomPaint (CircularTimerPainter)      │
                │       ├── Track ring                          │
                │       ├── Glow ring (MaskFilter.blur)         │
                │       ├── Gradient progress arc               │
                │       └── Tip dot                             │
                │   └── _TimerFace (digits + % label)          │
                ├── _GoalBar (linear progress)                  │
                └── _Controls                                   │
                    ├── GhostButton (stop)                      │
                    ├── _PlayPauseButton (gradient circle)      │
                    └── GhostButton (spacer)                   ─┘
```

---

## Animation Inventory

| Element | Technique | Duration |
|---|---|---|
| Ring fill | `TweenAnimationBuilder` + `CustomPainter` | 600ms easeOutCubic |
| Ring glow | `MaskFilter.blur` on sweep gradient | continuous |
| Play/Pause icon swap | `AnimatedSwitcher` + `ScaleTransition` | 250ms |
| Button press | `AnimationController` scale 1.0→0.92 | 120ms |
| Screen entry | `flutter_animate` fadeIn + slideY | 400–600ms |
| Settings sheet | `DraggableScrollableSheet` | system |
| Chart bars/lines | `fl_chart` built-in animation | 800ms |
| Progress bars | `TweenAnimationBuilder` | 800ms easeOutCubic |
| Goal stepper value | `AnimatedSwitcher` | 200ms |
| Status chip color | `AnimatedOpacity` | 300ms |

---

## Future Roadmap

1. **Sync** — Supabase real-time for live leaderboard
2. **Notifications** — local push when daily goal reached
3. **Pomodoro mode** — interval timer with break rounds
4. **Widgets** — iOS/Android home screen live activity
5. **Watch** — Apple Watch / WearOS companion
