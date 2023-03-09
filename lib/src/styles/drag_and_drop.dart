import 'package:flutter_week_view/src/event.dart';

/// Triggered when the user performs a drag-and-drop in an event. The [event]
/// is the same original event, unchanged, while [newStartTime] contains the
/// time corresponding to where the event was dropped. A common behavior in this
/// callback is to shift the event's start and end dates (you may use
/// [FlutterWeekViewEvent.shiftEventTo]) and then call setState to update the UI.
typedef EventDragCallback = Function(FlutterWeekViewEvent event, DateTime newStartTime);

enum DragStartingGesture {
  /// Drag will start as soon as the user starts dragging an event. This is more
  /// suited for desktop/web UX.
  tap,

  /// Drag will start after a long press on the event. This is more suited for
  /// mobile UX.
  longPress
}

/// Configures the behavior of drag-and-drop of events.
class DragAndDropOptions {
  /// Triggered when the user performs a drag-and-drop in an event.
  final EventDragCallback onEventDragged;

  /// If true, drag-and-drop will be restricted to the vertical axis. If there's
  /// no need to drag events horizontally, this is a smoother user experience.
  ///
  /// However, you may want to allow users to also move events horizontally. For
  /// example, if you have a WeekView displaying multiple days, and you want to
  /// allow users to move events between days. In that case, setting this to
  /// false will allow drag-and-drop in both axis.
  final bool allowOnlyVerticalDrag;

  /// Which gesture the user should perform to start dragging an event.
  final DragStartingGesture startingGesture;

  DragAndDropOptions({
    required this.onEventDragged,
    this.allowOnlyVerticalDrag = true,
    this.startingGesture = DragStartingGesture.tap,
  });
}
