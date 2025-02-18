import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/styles/zoomable_header_widget.dart';
import 'package:flutter_week_view/src/utils/utils.dart';

/// Builds an event text widget.
typedef EventTextBuilder<E extends FlutterWeekViewEventMixin<E>> = Widget Function(
  E event,
  TimeFormatter timeFormatter,
  TextStyle textStyle,
  double height,
  double width,
);

/// Represents a flutter week view event.
mixin FlutterWeekViewEventMixin<T extends FlutterWeekViewEventMixin<T>> {
  /// The event title.
  String get title;

  /// The event description.
  String get description;

  /// The event start date & time.
  DateTime get start;

  /// The event end date & time.
  DateTime get end;

  /// Shifts the start and end times, so that the event's duration is unaltered
  /// and the event now starts in [newStartTime].
  T shiftEventTo(DateTime newStartTime) {
    DateTime end = this.end.add(newStartTime.difference(this.start));
    DateTime start = newStartTime;
    return copyWith(start: start, end: end);
  }

  /// Copies this instance with the given parameters.
  T copyWith({
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
  });
}

/// A non-abstract flutter week view event.
class FlutterWeekViewEvent with FlutterWeekViewEventMixin<FlutterWeekViewEvent> implements Comparable<FlutterWeekViewEvent> {
  @override
  final String title;

  @override
  final String description;

  @override
  final DateTime start;

  @override
  final DateTime end;

  /// Creates a new flutter week view event instance.
  FlutterWeekViewEvent({
    required this.title,
    required this.description,
    required DateTime start,
    required DateTime end,
  })  : start = start.yearMonthDayHourMinute,
        end = end.yearMonthDayHourMinute;

  @override
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

/// A non-abstract flutter week view event that also holds a value.
class FlutterWeekViewEventWithValue<T> extends FlutterWeekViewEvent {
  /// The value.
  final T value;

  /// Creates a new flutter week view event with value instance.
  FlutterWeekViewEventWithValue({
    required super.title,
    required super.description,
    required super.start,
    required super.end,
    required this.value,
  });

  @override
  FlutterWeekViewEventWithValue<T> copyWith({
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    T? value,
  }) =>
      FlutterWeekViewEventWithValue(
        title: title ?? this.title,
        description: description ?? this.description,
        start: start ?? this.start,
        end: end ?? this.end,
        value: value ?? this.value,
      );

  @override
  int compareTo(FlutterWeekViewEvent other) {
    int result = super.compareTo(other);
    if (result == 0 && value is Comparable<T> && other is FlutterWeekViewEventWithValue<T>) {
      return (value as Comparable<T>).compareTo(other.value);
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (other is! FlutterWeekViewEventWithValue) {
      return super == other;
    }
    return super == other && value == other.value;
  }

  @override
  int get hashCode => Object.hash(title, description, start, end, value);
}
