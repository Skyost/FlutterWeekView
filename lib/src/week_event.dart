import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/utils/builders.dart';
import 'package:flutter_week_view/src/utils/utils.dart';
import 'package:flutter_week_view/src/widgets/day_view.dart';

// /// Builds an event text widget.
// typedef EventTextBuilder = Widget Function(FlutterWeekViewEvent event,
//     BuildContext context, DayView dayView, double height, double width);

/// Represents a flutter week view event.
class WeekEvent extends Comparable<WeekEvent> {
  /// The event start date & time.
  final TimeOfDay start;

  /// The event end date & time.
  final TimeOfDay end;

  /// day of week
  final List<int> day;

  ///
  final Widget child;

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
  // final EventTextBuilder eventTextBuilder;

  /// Creates a new flutter week view event instance.
  WeekEvent({
    @required this.start,
    @required this.end,
    @required this.day,
    this.child,
    this.backgroundColor = const Color(0xCC2196F3),
    this.decoration,
    this.textStyle = const TextStyle(color: Colors.white),
    this.padding = const EdgeInsets.all(10),
    this.margin,
    this.onTap,
    this.onLongPress,
    // this.eventTextBuilder,
  })  : assert(start != null),
        assert(end != null),
        assert(day != null);

  /// Builds the event widget.
  Widget build(
      BuildContext context, DayView dayView, double height, double width) {
    height = height - (padding?.top ?? 0.0) - (padding?.bottom ?? 0.0);
    width = width - (padding?.left ?? 0.0) - (padding?.right ?? 0.0);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
          decoration: decoration ??
              (backgroundColor != null
                  ? BoxDecoration(color: backgroundColor)
                  : null),
          margin: margin,
          padding: padding,
          // child: (eventTextBuilder ?? DefaultBuilders.defaultEventTextBuilder)(
          //   this,
          //   context,
          //   dayView,
          //   math.max(0.0, height),
          //   math.max(0.0, width),
          // ),
          child: const Text('aa')),
    );
  }

  double getTopOffset(double height) {
    final minuteHeight = height / 840;
    return minuteHeight * (start.hour * 60 + start.minute);
  }

  @override
  int compareTo(WeekEvent other) {
    return 1;
  }
}
