import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/day_view.dart';
import 'package:flutter_week_view/src/utils.dart';

/// Represents a flutter week view event.
class FlutterWeekViewEvent extends Comparable<FlutterWeekViewEvent> {
  /// The event title.
  final String title;

  /// The event description.
  final String description;

  /// The event start date & time.
  final DateTime start;

  /// The event end date & time.
  final DateTime end;

  /// The event widget background color.
  final Color backgroundColor;

  /// The event widget decoration.
  final BoxDecoration decoration;

  /// The event text widget text style.
  final TextStyle textStyle;

  /// The event widget padding.
  final EdgeInsets padding;

  /// The event widget margin.
  final EdgeInsets margin;

  /// The event widget tap event.
  final VoidCallback onTap;

  /// The event widget long press event.
  final VoidCallback onLongPress;

  /// The event text builder.
  final EventTextBuilder eventTextBuilder;

  /// Creates a new flutter week view event instance.
  FlutterWeekViewEvent({
    @required this.title,
    @required this.description,
    @required DateTime start,
    @required DateTime end,
    this.backgroundColor = const Color(0xCC2196F3),
    this.decoration,
    this.textStyle = const TextStyle(color: Colors.white),
    this.padding = const EdgeInsets.all(10),
    this.margin,
    this.onTap,
    this.onLongPress,
    this.eventTextBuilder,
  })  : start = DateTime(start.year, start.month, start.day, start.hour, start.minute),
        end = DateTime(end.year, end.month, end.day, end.hour, end.minute),
        assert(title != null),
        assert(description != null),
        assert(start != null),
        assert(end != null);

  /// Builds the event widget.
  Widget build(BuildContext context, DayView dayView, double height, double width) {
    height = height - (padding?.top ?? 0.0) - (padding?.bottom ?? 0.0);
    width = width - (padding?.left ?? 0.0) - (padding?.right ?? 0.0);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: decoration ?? (backgroundColor != null ? BoxDecoration(color: backgroundColor) : null),
        margin: margin,
        padding: padding,
        child: (eventTextBuilder ?? DefaultBuilders.defaultEventTextBuilder)(
          this,
          context,
          dayView,
          math.max(0.0, height),
          math.max(0.0, width),
        ),
      ),
    );
  }

  @override
  int compareTo(FlutterWeekViewEvent other) {
    int result = start.compareTo(other.start);
    if (result != 0) {
      return result;
    }
    return end.compareTo(other.end);
  }
}
