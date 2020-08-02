import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:flutter_week_view/src/headers.dart';
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
  /// The header size (usually limited to the day bar). Defaults to 60.
  final double headerSize;

  /// Creates a new zoomable header widget style instance.
  const ZoomableHeaderWidgetStyle({
    double headerSize,
  }) : headerSize = (headerSize ?? 40) < 0 ? 0 : (headerSize ?? 40);
}

/// Allows to style a day view.
class DayViewStyle extends ZoomableHeaderWidgetStyle {
  /// An hour row height (with a zoom factor set to 1). Defaults to 60.
  final double hourRowHeight;

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
    double headerSize,
    double hourRowHeight,
    Color backgroundColor,
    this.backgroundRulesColor = const Color(0x1A000000),
    this.currentTimeRuleColor = Colors.pink,
    double currentTimeRuleHeight,
    this.currentTimeCircleColor,
    double currentTimeCircleRadius,
    CurrentTimeCirclePosition currentTimeCirclePosition,
  })  : hourRowHeight = (hourRowHeight ?? 60) < 0 ? 0 : (hourRowHeight ?? 60),
        backgroundColor = backgroundColor ?? const Color(0xFFF2F2F2),
        currentTimeRuleHeight = (currentTimeRuleHeight ?? 1) < 0 ? 0 : (currentTimeRuleHeight ?? 1),
        currentTimeCircleRadius = (currentTimeCircleRadius ?? 7.5) < 0 ? 0 : (currentTimeCircleRadius ?? 7.5),
        currentTimeCirclePosition = currentTimeCirclePosition ?? CurrentTimeCirclePosition.right,
        super(headerSize: headerSize);

  /// Allows to automatically customize the day view background color according to the specified date.
  DayViewStyle.fromDate({
    @required DateTime date,
    double headerSize,
    double hourRowHeight,
    Color backgroundRulesColor = const Color(0x1A000000),
    Color currentTimeRuleColor = Colors.pink,
    double currentTimeRuleHeight,
    Color currentTimeCircleColor,
    double currentTimeCircleRadius,
    CurrentTimeCirclePosition currentTimeCirclePosition,
  }) : this(
          headerSize: headerSize,
          hourRowHeight: hourRowHeight,
          backgroundColor: Utils.sameDay(date) ? const Color(0xFFE3F5FF) : null,
          backgroundRulesColor: backgroundRulesColor,
          currentTimeRuleColor: currentTimeRuleColor,
          currentTimeRuleHeight: currentTimeRuleHeight,
          currentTimeCircleColor: currentTimeCircleColor,
          currentTimeCircleRadius: currentTimeCircleRadius,
          currentTimeCirclePosition: currentTimeCirclePosition,
        );

  /// Allows to copy the current style instance with your own properties.
  DayViewStyle copyWith({
    double headerSize,
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
        headerSize: headerSize ?? this.headerSize,
        hourRowHeight: hourRowHeight ?? this.hourRowHeight,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        backgroundRulesColor: backgroundRulesColor ?? this.backgroundRulesColor,
        currentTimeRuleColor: currentTimeRuleColor ?? this.currentTimeRuleColor,
        currentTimeRuleHeight: currentTimeRuleHeight ?? this.currentTimeRuleHeight,
        currentTimeCircleColor: currentTimeCircleColor ?? this.currentTimeCircleColor,
        currentTimeCircleRadius: currentTimeCircleRadius ?? this.currentTimeCircleRadius,
        currentTimeCirclePosition: currentTimeCirclePosition ?? this.currentTimeCirclePosition,
      );

  /// Creates the background painter.
  CustomPainter createBackgroundPainter({
    @required DayView dayView,
    @required TopOffsetCalculator topOffsetCalculator,
  }) =>
      _EventsColumnBackgroundPainter(
        minimumTime: dayView.minimumTime,
        maximumTime: dayView.maximumTime,
        topOffsetCalculator: topOffsetCalculator,
        dayViewStyle: this,
        interval: dayView.hoursColumnStyle.interval,
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
  /// Defaults to [Colors.black12].
  final Color dayViewSeparatorColor;

  /// Creates a new week view style instance.
  const WeekViewStyle({
    double headerSize,
    this.dayViewWidth,
    double dayViewSeparatorWidth,
    this.dayViewSeparatorColor = Colors.black12,
  })  : dayViewSeparatorWidth = (dayViewSeparatorWidth ?? 0) < 0 ? 0 : (dayViewSeparatorWidth ?? 0),
        super(headerSize: headerSize);

  /// Allows to copy the current style instance with your own properties.
  WeekViewStyle copyWith({
    double headerSize,
    double dayViewWidth,
    double dayViewSeparatorWidth,
    double dayViewSeparatorColor,
  }) =>
      WeekViewStyle(
        headerSize: headerSize ?? this.headerSize,
        dayViewWidth: dayViewWidth ?? this.dayViewWidth,
        dayViewSeparatorWidth: dayViewSeparatorWidth ?? this.dayViewSeparatorWidth,
        dayViewSeparatorColor: dayViewSeparatorColor ?? this.dayViewSeparatorColor,
      );
}

/// Allows to configure the hours column style.
class HoursColumnStyle {
  /// The hour formatter. Defaults to 24-hour HH:MM, e.g., 15:00.
  final TimeFormatter timeFormatter;

  /// The hours column text style. Defaults to light gray text.
  final TextStyle textStyle;

  /// The hours column width. Defaults to 60.
  final double width;

  /// The hours column background color. Defaults to [Colors.white].
  final Color color;

  /// The hours column decoration. Defaults to null.
  final Decoration decoration;

  /// The hours text alignment. Defaults to [Alignment.center].
  final Alignment textAlignment;

  /// The interval between two durations displayed on the hours column. Defaults to [Duration(hours: 1)].
  final Duration interval;

  /// Creates a new hour column style instance.
  const HoursColumnStyle({
    TimeFormatter timeFormatter,
    TextStyle textStyle,
    double width,
    Color color,
    this.decoration,
    Alignment textAlignment,
    Duration interval,
  })  : timeFormatter = timeFormatter ?? DefaultBuilders.defaultTimeFormatter,
        textStyle = textStyle ?? const TextStyle(color: Colors.black54),
        width = (width ?? 60) < 0 ? 0 : (width ?? 60),
        color = color ?? Colors.white,
        textAlignment = textAlignment ?? Alignment.center,
        interval = interval ?? const Duration(hours: 1);

  /// Allows to copy the current style instance with your own properties.
  HoursColumnStyle copyWith({
    TimeFormatter timeFormatter,
    TextStyle textStyle,
    double width,
    Color color,
    Decoration decoration,
    Alignment textAlignment,
    Duration interval,
  }) =>
      HoursColumnStyle(
        timeFormatter: timeFormatter ?? this.timeFormatter,
        textStyle: textStyle ?? this.textStyle,
        width: width ?? this.width,
        color: color ?? this.color,
        decoration: decoration ?? this.decoration,
        textAlignment: textAlignment ?? this.textAlignment,
        interval: interval ?? this.interval,
      );
}

/// Allows to configure the day bar style.
class DayBarStyle {
  /// The day formatter. Defaults to YYYY-MM-DD, e.g., 2020-01-15.
  final DateFormatter dateFormatter;

  /// The day bar text style. Defaults to null, which will then format according to [DayBar.textStyle].
  final TextStyle textStyle;

  /// The day bar background color. Defaults to light gray.
  final Color color;

  /// The day bar decoration. Defaults to null.
  final Decoration decoration;

  /// The day bar text alignment. Defaults to [Alignment.center].
  final Alignment textAlignment;

  /// Creates a new day bar style instance.
  const DayBarStyle({
    DateFormatter dateFormatter,
    this.textStyle,
    Color color,
    this.decoration,
    Alignment textAlignment,
  })  : dateFormatter = dateFormatter ?? DefaultBuilders.defaultDateFormatter,
        color = color ?? const Color(0xFFEBEBEB),
        textAlignment = textAlignment ?? Alignment.center;

  /// Creates a new day bar style according to the specified date.
  DayBarStyle.fromDate({
    @required DateTime date,
    DateFormatter dateFormatter,
    TextStyle textStyle,
    Color color,
    Decoration decoration,
    Alignment textAlignment,
  }) : this(
          dateFormatter: dateFormatter,
          textStyle: textStyle ??
              TextStyle(
                color: Utils.sameDay(date) ? Colors.blue[800] : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
          color: color,
          decoration: decoration,
          textAlignment: textAlignment,
        );

  /// Allows to copy the current style instance with your own properties.
  DayBarStyle copyWith({
    DateFormatter dateFormatter,
    TextStyle textStyle,
    Color color,
    Decoration decoration,
    Alignment textAlignment,
  }) =>
      DayBarStyle(
        dateFormatter: dateFormatter ?? this.dateFormatter,
        textStyle: textStyle ?? this.textStyle,
        color: color ?? this.color,
        decoration: decoration ?? this.decoration,
        textAlignment: textAlignment ?? this.textAlignment,
      );
}

/// The current time circle position enum.
enum CurrentTimeCirclePosition {
  /// Whether it should be placed at the start of the current time rule.
  left,

  /// Whether it should be placed at the end of the current time rule.
  right,
}

/// The events column background painter.
class _EventsColumnBackgroundPainter extends CustomPainter {
  /// The minimum time to display.
  final HourMinute minimumTime;

  /// The maximum time to display.
  final HourMinute maximumTime;

  /// The top offset calculator.
  final TopOffsetCalculator topOffsetCalculator;

  /// The day view style.
  final DayViewStyle dayViewStyle;

  /// The interval between two lines.
  final Duration interval;

  /// Creates a new events column background painter.
  _EventsColumnBackgroundPainter({
    @required this.minimumTime,
    @required this.maximumTime,
    @required this.topOffsetCalculator,
    @required this.dayViewStyle,
    @required this.interval,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dayViewStyle.backgroundColor != null) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = dayViewStyle.backgroundColor);
    }

    if (dayViewStyle.backgroundRulesColor != null) {
      final List<HourMinute> sideTimes = HoursColumn.getSideTimes(minimumTime, maximumTime, interval);
      for (HourMinute time in sideTimes) {
        double topOffset = topOffsetCalculator(time);
        canvas.drawLine(Offset(0, topOffset), Offset(size.width, topOffset), Paint()..color = dayViewStyle.backgroundRulesColor);
      }
    }
  }

  @override
  bool shouldRepaint(_EventsColumnBackgroundPainter oldDayViewBackgroundPainter) {
    return dayViewStyle.backgroundColor != oldDayViewBackgroundPainter.dayViewStyle.backgroundColor || dayViewStyle.backgroundRulesColor != oldDayViewBackgroundPainter.dayViewStyle.backgroundRulesColor || topOffsetCalculator != oldDayViewBackgroundPainter.topOffsetCalculator;
  }
}
