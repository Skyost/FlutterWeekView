import 'package:flutter_week_view/src/event.dart';

/// Triggered when the user performs a resize in an event. The [event]
/// is the same original event, unchanged, while [newEndTime] contains the
/// time corresponding to where the event's end was dragged to. A common
/// behavior in this callback is to update the event with the new end time
/// and call setState to update the UI.
typedef EventResizeCallback = Function(FlutterWeekViewEvent event, DateTime newEndTime);

/// Configures the behavior for resizing events. When resizing is enabled, users
/// can drag the end of events to increase/decrease their duration.
class ResizeEventOptions {
  /// Triggered when the user performs a resize in an event.
  final EventResizeCallback onEventResized;

  /// When resizing, the event end is snapped to an imaginary grid, for better
  /// user experience. This variable controls the granularity of that grid,
  /// which defaults to 15 minutes (that is, events will be snapped to clock
  /// times ending in :00, :15, :30 and :45). To disable this snap, set this
  /// value to [Duration.zero].
  final Duration snapToGridGranularity;

  /// Restricts resizing events to be shorter than this duration. Defaults to
  /// 15 minutes.
  final Duration minimumEventDuration;

  ResizeEventOptions({
    required this.onEventResized,
    this.snapToGridGranularity = const Duration(minutes: 15),
    this.minimumEventDuration = const Duration(minutes: 15),
  });
}
