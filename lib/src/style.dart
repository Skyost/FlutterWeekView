import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/hour_minute.dart';
import 'package:flutter_week_view/src/utils.dart';

/// Returns a string from a specified date.
typedef DateFormatter = String Function(int year, int month, int day);

/// Returns a string from a specified hour.
typedef TimeFormatter = String Function(HourMinute time);

/// Allows to builder a vertical divider according to the specified date.
typedef VerticalDividerBuilder = VerticalDivider Function(DateTime date);

/// Allows to style a zoomable header widget style.
class ZoomableHeaderWidgetStyle {
  /// The day formatter. Defaults to YYYY-MM-DD, e.g., 2020-01-15.
  final DateFormatter dateFormatter;

  /// The hour formatter. Defaults to 24-hour HH:MM, e.g., 15:00.
  final TimeFormatter timeFormatter;

  /// The day bar text style. Defaults to null, which will then format according to [DayBar.textStyle].
  final TextStyle dayBarTextStyle;

  /// The day bar height. Defaults to 40.
  final double dayBarHeight;

  /// The day bar background color. Defaults to light gray.
  final Color dayBarBackgroundColor;

  /// The hours column text style. Defaults to light gray text.
  final TextStyle hoursColumnTextStyle;

  /// The hours column width. Defaults to 60.
  final double hoursColumnWidth;

  /// The hours column background color. Defaults to [Colors.white].
  final Color hoursColumnBackgroundColor;

  /// An hour row height (with a zoom factor set to 1). Defaults to 60.
  final double hourRowHeight;

  /// Creates a new zoomable header widget style instance.
  const ZoomableHeaderWidgetStyle({
    DateFormatter dateFormatter,
    TimeFormatter timeFormatter,
    this.dayBarTextStyle,
    double dayBarHeight,
    Color dayBarBackgroundColor,
    TextStyle hoursColumnTextStyle,
    double hoursColumnWidth,
    Color hoursColumnBackgroundColor,
    double hourRowHeight,
  })  : dateFormatter = dateFormatter ?? DefaultBuilders.defaultDateFormatter,
        timeFormatter = timeFormatter ?? DefaultBuilders.defaultTimeFormatter,
        dayBarHeight = (dayBarHeight ?? 40) < 0 ? 0 : (dayBarHeight ?? 40),
        dayBarBackgroundColor = dayBarBackgroundColor ?? const Color(0xFFEBEBEB),
        hoursColumnTextStyle = hoursColumnTextStyle ?? const TextStyle(color: Colors.black54),
        hoursColumnWidth = (hoursColumnWidth ?? 60) < 0 ? 0 : (hoursColumnWidth ?? 60),
        hoursColumnBackgroundColor = hoursColumnBackgroundColor ?? Colors.white,
        hourRowHeight = (hourRowHeight ?? 60) < 0 ? 0 : (hourRowHeight ?? 60);
}

/// Allows to style a day view.
class DayViewStyle extends ZoomableHeaderWidgetStyle {
  /// The background color for the day view main column.
  ///
  /// Defaults to a light blue if the DayView's date is today (make sure to use [DayViewStyle.fromDate]
  /// if you're creating your own DayViewStyle and want this behaviour). Otherwise, defaults to a
  /// light gray.
  final Color backgroundColor;

  /// The rules color, i.e., the color of the background horizontal lines positioned along with
  /// each hour shown in the hours column.
  ///
  /// Defaults to a semi-transparent gray.
  final Color backgroundRulesColor;

  /// The current time rule color, i.e., the color of the horizontal line in the day view column,
  /// positioned at the current time of the day. It is only shown if the DayView's date is today.
  ///
  /// Defaults to [Colors.pink].
  final Color currentTimeRuleColor;

  /// The current time rule height.
  ///
  /// Defaults to 1 pixel.
  final double currentTimeRuleHeight;

  /// The current time circle color. This is a small circle to be shown along with the horizontal
  /// time rule in the hours column, typically colored the same as [currentTimeRuleColor].
  ///
  /// If null, the circle is not drawn.
  final Color currentTimeCircleColor;

  /// The current time circle radius.
  ///
  /// If null, the circle is not drawn.
  /// Defaults to 7.5 pixels.
  final double currentTimeCircleRadius;

  /// The current time rule position, i.e., the position of the current time circle in the day view column.
  ///
  /// Defaults to [CurrentTimeCirclePosition.right].
  final CurrentTimeCirclePosition currentTimeCirclePosition;

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
    double currentTimeRuleHeight,
    this.currentTimeCircleColor,
    double currentTimeCircleRadius,
    CurrentTimeCirclePosition currentTimeCirclePosition,
  })  : backgroundColor = backgroundColor ?? const Color(0xFFF2F2F2),
        currentTimeRuleHeight = (currentTimeRuleHeight ?? 1) < 0 ? 0 : (currentTimeRuleHeight ?? 1),
        currentTimeCircleRadius = (currentTimeCircleRadius ?? 7.5) < 0 ? 0 : (currentTimeCircleRadius ?? 7.5),
        currentTimeCirclePosition = currentTimeCirclePosition ?? CurrentTimeCirclePosition.right,
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
    Color backgroundRulesColor = const Color(0x1A000000),
    Color currentTimeRuleColor = Colors.pink,
    double currentTimeRuleHeight,
    Color currentTimeCircleColor,
    double currentTimeCircleRadius,
    CurrentTimeCirclePosition currentTimeCirclePosition,
  }) : this(
          dateFormatter: dateFormatter,
          timeFormatter: timeFormatter,
          dayBarTextStyle: dayBarTextStyle,
          dayBarHeight: dayBarHeight,
          dayBarBackgroundColor: dayBarBackgroundColor,
          hoursColumnTextStyle: hoursColumnTextStyle,
          hoursColumnWidth: hoursColumnWidth,
          hoursColumnBackgroundColor: hoursColumnBackgroundColor,
          hourRowHeight: hourRowHeight,
          backgroundColor: Utils.sameDay(date) ? const Color(0xFFE3F5FF) : const Color(0xFFF2F2F2),
          backgroundRulesColor: backgroundRulesColor,
          currentTimeRuleColor: currentTimeRuleColor,
          currentTimeRuleHeight: currentTimeRuleHeight,
          currentTimeCircleColor: currentTimeCircleColor,
          currentTimeCircleRadius: currentTimeCircleRadius,
          currentTimeCirclePosition: currentTimeCirclePosition,
        );

  /// Allows to copy the current style instance with your own properties.
  DayViewStyle copyWith({
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
    Color backgroundRulesColor,
    Color currentTimeRuleColor,
    double currentTimeRuleHeight,
    Color currentTimeCircleColor,
    double currentTimeCircleRadius,
    CurrentTimeCirclePosition currentTimeCirclePosition,
  }) =>
      DayViewStyle(
        dateFormatter: dateFormatter ?? this.dateFormatter,
        timeFormatter: timeFormatter ?? this.timeFormatter,
        dayBarTextStyle: dayBarTextStyle ?? this.dayBarTextStyle,
        dayBarHeight: dayBarHeight ?? this.dayBarHeight,
        dayBarBackgroundColor: dayBarBackgroundColor ?? this.dayBarBackgroundColor,
        hoursColumnTextStyle: hoursColumnTextStyle ?? this.hoursColumnTextStyle,
        hoursColumnWidth: hoursColumnWidth ?? this.hoursColumnWidth,
        hoursColumnBackgroundColor: hoursColumnBackgroundColor ?? this.hoursColumnBackgroundColor,
        hourRowHeight: hourRowHeight ?? this.hourRowHeight,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        backgroundRulesColor: backgroundRulesColor ?? this.backgroundRulesColor,
        currentTimeRuleColor: currentTimeRuleColor ?? this.currentTimeRuleColor,
        currentTimeRuleHeight: currentTimeRuleHeight ?? this.currentTimeRuleHeight,
        currentTimeCircleColor: currentTimeCircleColor ?? this.currentTimeCircleColor,
        currentTimeCircleRadius: currentTimeCircleRadius ?? this.currentTimeCircleRadius,
        currentTimeCirclePosition: currentTimeCirclePosition ?? this.currentTimeCirclePosition,
      );
}

/// Allows to style a week view.
class WeekViewStyle extends ZoomableHeaderWidgetStyle {
  /// A day view width.
  ///
  /// Defaults to the entire width available for the week view widget.
  final double dayViewWidth;

  /// The separator width between day views.
  ///
  /// Defaults to zero.
  final double dayViewSeparatorWidth;

  /// The separator color between day views.
  ///
  /// Defaults to zero.
  final Color dayViewSeparatorColor;

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
    double dayViewSeparatorWidth,
    this.dayViewSeparatorColor,
  })  : dayViewSeparatorWidth = (dayViewSeparatorWidth ?? 0) < 0 ? 0 : (dayViewSeparatorWidth ?? 0),
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

  /// Allows to copy the current style instance with your own properties.
  WeekViewStyle copyWith({
    DateFormatter dateFormatter,
    TimeFormatter timeFormatter,
    TextStyle dayBarTextStyle,
    double dayBarHeight,
    Color dayBarBackgroundColor,
    TextStyle hoursColumnTextStyle,
    double hoursColumnWidth,
    Color hoursColumnBackgroundColor,
    double hourRowHeight,
    double dayViewWidth,
    double dayViewSeparatorWidth,
    double dayViewSeparatorColor,
  }) =>
      WeekViewStyle(
        dateFormatter: dateFormatter ?? this.dateFormatter,
        timeFormatter: timeFormatter ?? this.timeFormatter,
        dayBarTextStyle: dayBarTextStyle ?? this.dayBarTextStyle,
        dayBarHeight: dayBarHeight ?? this.dayBarHeight,
        dayBarBackgroundColor: dayBarBackgroundColor ?? this.dayBarBackgroundColor,
        hoursColumnTextStyle: hoursColumnTextStyle ?? this.hoursColumnTextStyle,
        hoursColumnWidth: hoursColumnWidth ?? this.hoursColumnWidth,
        hoursColumnBackgroundColor: hoursColumnBackgroundColor ?? this.hoursColumnBackgroundColor,
        hourRowHeight: hourRowHeight ?? this.hourRowHeight,
        dayViewWidth: dayViewWidth ?? this.dayViewWidth,
        dayViewSeparatorWidth: dayViewSeparatorWidth ?? this.dayViewSeparatorWidth,
        dayViewSeparatorColor: dayViewSeparatorColor ?? this.dayViewSeparatorColor,
      );
}

/// The current time circle position enum.
enum CurrentTimeCirclePosition {
  /// Whether it should be placed at the start of the current time rule.
  left,

  /// Whether it should be placed at the end of the current time rule.
  right,
}
