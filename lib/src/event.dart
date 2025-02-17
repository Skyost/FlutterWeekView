import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/styles/zoomable_header_widget.dart';
import 'package:flutter_week_view/src/utils/utils.dart';

/// Builds an event text widget.
typedef EventTextBuilder = Widget Function(FlutterWeekViewEvent event, TimeFormatter timeFormatter, TextStyle textStyle, double height, double width);

/// Represents a flutter week view event.
class FlutterWeekViewEvent implements Comparable<FlutterWeekViewEvent> {
  /// The event title.
  final String title;

  /// The event description.
  final String description;

  /// The event start date & time.
  final DateTime start;

  /// The event end date & time.
  final DateTime end;

  /// Creates a new flutter week view event instance.
  FlutterWeekViewEvent({
    required this.title,
    required this.description,
    required DateTime start,
    required DateTime end,
  })  : start = start.yearMonthDayHourMinute,
        end = end.yearMonthDayHourMinute;

  /// Shifts the start and end times, so that the event's duration is unaltered
  /// and the event now starts in [newStartTime].
  FlutterWeekViewEvent shiftEventTo(DateTime newStartTime) {
    DateTime end = this.end.add(newStartTime.difference(this.start));
    DateTime start = newStartTime;
    return copyWith(start: start, end: end);
  }

  /// Copies this instance with the given parameters.
  FlutterWeekViewEvent copyWith({
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
  }) =>
      FlutterWeekViewEvent(
        title: title ?? this.title,
        description: description ?? this.description,
        start: start ?? this.start,
        end: end ?? this.end,
      );

  @override
  int compareTo(FlutterWeekViewEvent other) {
    int result = start.compareTo(other.start);
    if (result != 0) {
      return result;
    }
    return end.compareTo(other.end);
  }

  @override
  bool operator ==(Object other) {
    if (other is! FlutterWeekViewEvent) {
      return super == other;
    }
    return title == other.title && description == other.description && start.isAtSameMomentAs(other.start) && end.isAtSameMomentAs(other.end);
  }

  @override
  int get hashCode => Object.hash(title, description, start, end);
}
