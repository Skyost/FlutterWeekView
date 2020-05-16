import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/hour_minute.dart';
import 'package:flutter_week_view/src/utils.dart';

/// Returns a string from a specified date.
typedef DateFormatter = String Function(int year, int month, int day);

/// Returns a string from a specified hour.
typedef TimeFormatter = String Function(HourMinute time);

/// Allows to style a zoomable header widget style.
class ZoomableHeaderWidgetStyle {
  /// The day formatter.
  final DateFormatter dateFormatter;

  /// The hour formatter.
  final TimeFormatter timeFormatter;

  /// The day bar text style.
  final TextStyle dayBarTextStyle;

  /// The day bar height.
  final double dayBarHeight;

  /// The day bar background color.
  final Color dayBarBackgroundColor;

  /// The hours column text style.
  final TextStyle hoursColumnTextStyle;

  /// The hours column width.
  final double hoursColumnWidth;

  /// The hours column background color.
  final Color hoursColumnBackgroundColor;

  /// An hour row height (with a zoom factor set to 1).
  final double hourRowHeight;

  /// Creates a new zoomable header widget style instance.
  const ZoomableHeaderWidgetStyle({
    DateFormatter dateFormatter,
    TimeFormatter timeFormatter,
    this.dayBarTextStyle,
    double dayBarHeight,
    this.dayBarBackgroundColor,
    this.hoursColumnTextStyle,
    double hoursColumnWidth,
    this.hoursColumnBackgroundColor,
    double hourRowHeight,
  })  : dateFormatter = dateFormatter ?? DefaultBuilders.defaultDateFormatter,
        timeFormatter = timeFormatter ?? DefaultBuilders.defaultTimeFormatter,
        dayBarHeight = (dayBarHeight ?? 40) < 0 ? 0 : (dayBarHeight ?? 40),
        hoursColumnWidth = (hoursColumnWidth ?? 60) < 0 ? 0 : (hoursColumnWidth ?? 60),
        hourRowHeight = (hourRowHeight ?? 60) < 0 ? 0 : (hourRowHeight ?? 60);
}

/// Allows to style a day view.
class DayViewStyle extends ZoomableHeaderWidgetStyle {
  /// The background color.
  final Color backgroundColor;

  /// The rules color.
  final Color backgroundRulesColor;

  /// The current time rule color.
  final Color currentTimeRuleColor;

  /// The current time circle color.
  final Color currentTimeCircleColor;

  /// Creates a new day view style instance.
  const DayViewStyle({
    DateFormatter dateFormatter,
    TimeFormatter timeFormatter,
    TextStyle dayBarTextStyle,
    double dayBarHeight,
    Color dayBarBackgroundColor,
    TextStyle hoursColumnTextStyle,
    double hoursColumnWidth,
    Color hoursColumnBackgroundColor,
    double hourRowHeight,
    Color backgroundColor,
    this.backgroundRulesColor = const Color(0x1A000000),
    this.currentTimeRuleColor = Colors.pink,
    this.currentTimeCircleColor,
  })  : backgroundColor = backgroundColor ?? const Color(0xFFF2F2F2),
        super(
          dateFormatter: dateFormatter,
          timeFormatter: timeFormatter,
          dayBarTextStyle: dayBarTextStyle,
          dayBarHeight: dayBarHeight,
          dayBarBackgroundColor: dayBarBackgroundColor,
          hoursColumnTextStyle: hoursColumnTextStyle,
          hoursColumnWidth: hoursColumnWidth,
          hoursColumnBackgroundColor: hoursColumnBackgroundColor,
          hourRowHeight: hourRowHeight,
        );

  /// Creates a new day view style instance from a given date.
  DayViewStyle.fromDate({
    DateFormatter dateFormatter,
    TimeFormatter timeFormatter,
    TextStyle dayBarTextStyle,
    double dayBarHeight,
    Color dayBarBackgroundColor,
    TextStyle hoursColumnTextStyle,
    double hoursColumnWidth,
    Color hoursColumnBackgroundColor,
    double hourRowHeight,
    @required DateTime date,
    this.backgroundRulesColor = const Color(0x1A000000),
    this.currentTimeRuleColor = Colors.pink,
    this.currentTimeCircleColor,
  })  : backgroundColor = Utils.sameDay(date) ? const Color(0xFFE3F5FF) : const Color(0xFFF2F2F2),
        super(
          dateFormatter: dateFormatter,
          timeFormatter: timeFormatter,
          dayBarTextStyle: dayBarTextStyle,
          dayBarHeight: dayBarHeight,
          dayBarBackgroundColor: dayBarBackgroundColor,
          hoursColumnTextStyle: hoursColumnTextStyle,
          hoursColumnWidth: hoursColumnWidth,
          hoursColumnBackgroundColor: hoursColumnBackgroundColor,
          hourRowHeight: hourRowHeight,
        );

  /// A day view style that should be placed in a week view.
  DayViewStyle inWeekView() => DayViewStyle(
        dateFormatter: dateFormatter,
        timeFormatter: timeFormatter,
        dayBarTextStyle: dayBarTextStyle,
        dayBarHeight: 0,
        dayBarBackgroundColor: dayBarBackgroundColor,
        hoursColumnTextStyle: hoursColumnTextStyle,
        hoursColumnWidth: 0,
        hoursColumnBackgroundColor: hoursColumnBackgroundColor,
        hourRowHeight: hourRowHeight,
        backgroundColor: backgroundColor,
        backgroundRulesColor: backgroundRulesColor,
        currentTimeRuleColor: currentTimeRuleColor,
        currentTimeCircleColor: currentTimeCircleColor,
      );
}

/// Allows to style a week view.
class WeekViewStyle extends ZoomableHeaderWidgetStyle {
  /// A day view width.
  final double dayViewWidth;

  /// Creates a new week view style instance.
  const WeekViewStyle({
    DateFormatter dateFormatter,
    TimeFormatter timeFormatter,
    TextStyle dayBarTextStyle,
    double dayBarHeight,
    Color dayBarBackgroundColor,
    TextStyle hoursColumnTextStyle,
    double hoursColumnWidth,
    Color hoursColumnBackgroundColor,
    double hourRowHeight,
    this.dayViewWidth,
  }) : super(
          dateFormatter: dateFormatter,
          timeFormatter: timeFormatter,
          dayBarTextStyle: dayBarTextStyle,
          dayBarHeight: dayBarHeight,
          dayBarBackgroundColor: dayBarBackgroundColor,
          hoursColumnTextStyle: hoursColumnTextStyle,
          hoursColumnWidth: hoursColumnWidth,
          hoursColumnBackgroundColor: hoursColumnBackgroundColor,
          hourRowHeight: hourRowHeight,
        );
}
