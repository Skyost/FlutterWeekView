import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/event.dart';
import 'package:flutter_week_view/src/styles/day_bar.dart';
import 'package:flutter_week_view/src/styles/day_view.dart';
import 'package:flutter_week_view/src/styles/hours_column.dart';
import 'package:flutter_week_view/src/styles/zoomable_header_widget.dart';
import 'package:flutter_week_view/src/utils/time_of_day.dart';
import 'package:flutter_week_view/src/utils/utils.dart';
import 'package:flutter_week_view/src/widgets/event.dart';
import 'package:flutter_week_view/src/widgets/zoomable_header_widget.dart';

/// Contains default builders and formatters.
class DefaultBuilders {
  /// Formats a day in YYYY-MM-DD format, e.g., 2020-01-15.
  static String defaultDateFormatter(
    int year,
    int month,
    int day,
  ) =>
      '$year-${Utils.addLeadingZero(month)}-${Utils.addLeadingZero(day)}';

  /// Formats a hour in 24-hour HH:MM format, e.g., 15:00.
  static String defaultTimeFormatter(
    TimeOfDay time,
  ) =>
      '${Utils.addLeadingZero(time.hour)}:${Utils.addLeadingZero(time.minute)}';

  /// Allows to calculate a top offset according to the specified hour row height.
  static double defaultTopOffsetCalculator(
    TimeOfDay time, {
    TimeOfDay minimumTime = TimeOfDayUtils.min,
    double hourRowHeight = 60,
  }) {
    TimeOfDay relative = time.subtract(minimumTime.asDuration);
    return (relative.hour + (relative.minute / 60)) * hourRowHeight;
  }

  /// Builds a date according to a list.
  static DateTime defaultDateCreator(
    List<DateTime> dates,
    int index,
  ) =>
      dates[index];

  /// Builds the current time indicator builder.
  static Widget defaultCurrentTimeIndicatorBuilder(
    DayViewStyle dayViewStyle,
    TopOffsetCalculator topOffsetCalculator,
    double hourColumnWidth,
    bool isRtl,
  ) {
    List<Widget> children = [
      if (dayViewStyle.currentTimeRuleHeight > 0 && dayViewStyle.currentTimeRuleColor != null)
        Expanded(
          child: Container(
            height: dayViewStyle.currentTimeRuleHeight,
            color: dayViewStyle.currentTimeRuleColor,
          ),
        ),
      if (dayViewStyle.currentTimeCircleRadius > 0 && dayViewStyle.currentTimeCircleColor != null)
        Container(
          height: dayViewStyle.currentTimeCircleRadius * 2,
          width: dayViewStyle.currentTimeCircleRadius * 2,
          decoration: BoxDecoration(
            color: dayViewStyle.currentTimeCircleColor,
            shape: BoxShape.circle,
          ),
        ),
    ];

    final timeIndicatorHeight = math.max(
      dayViewStyle.currentTimeRuleHeight,
      dayViewStyle.currentTimeCircleRadius * 2,
    );

    if (dayViewStyle.currentTimeCirclePosition == CurrentTimeCirclePosition.left) {
      children = children.reversed.toList();
    }

    return Positioned(
      top: topOffsetCalculator(TimeOfDay.now()) - timeIndicatorHeight / 2,
      left: isRtl ? 0 : hourColumnWidth,
      right: isRtl ? hourColumnWidth : 0,
      child: Row(children: children),
    );
  }

  /// Builds the time displayed on the side border.
  static Widget defaultHourColumnTimeBuilder(
    HourColumnStyle hourColumnStyle,
    TimeOfDay time,
  ) =>
      Text(
        hourColumnStyle.timeFormatter(time),
        style: hourColumnStyle.textStyle,
      );

  /// Builds the time displayed on the side border.
  static Widget defaultEventWidgetBuilder<E extends FlutterWeekViewEventMixin>(
    E event,
    double height,
    double width, {
    TimeFormatter? timeFormatter,
  }) =>
      FlutterWeekViewEventWidget<E>(
        event: event,
        height: height,
        width: width,
        timeFormatter: timeFormatter,
      );

  /// The default day view style builder.
  static DayViewStyle defaultDayViewStyleBuilder(
    DateTime date,
  ) =>
      DayViewStyle.fromDate(
        date: date,
      );

  /// The default day view style builder.
  static DayBarStyle defaultDayBarStyleBuilder(
    DateTime date,
  ) =>
      DayBarStyle.fromDate(
        date: date,
      );
}
