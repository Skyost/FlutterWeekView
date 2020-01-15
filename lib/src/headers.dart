import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/day_view.dart';
import 'package:flutter_week_view/src/utils.dart';

/// A widget which is showing both headers.
abstract class HeadersWidget extends StatefulWidget {
  /// The day formatter.
  final DateFormatter dateFormatter;

  /// The hour formatter.
  final HourFormatter hourFormatter;

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

  /// Creates a new header widget instance.
  HeadersWidget({
    this.dateFormatter = DefaultBuilders.defaultDateFormatter,
    this.hourFormatter = DefaultBuilders.defaultHourFormatter,
    this.dayBarTextStyle,
    double dayBarHeight = 40,
    this.dayBarBackgroundColor,
    this.hoursColumnTextStyle,
    double hoursColumnWidth = 60,
    this.hoursColumnBackgroundColor,
    double hourRowHeight = 60,
  })  : assert(dateFormatter != null),
        assert(hourFormatter != null),
        this.dayBarHeight = Math.max(0, dayBarHeight ?? 0),
        this.hoursColumnWidth = Math.max(0, hoursColumnWidth ?? 0),
        this.hourRowHeight = Math.max(0, hourRowHeight ?? 0);
}

/// A bar which is showing a day.
class DayBar extends StatelessWidget {
  /// The date.
  final DateTime date;

  /// The height.
  final double height;

  /// The background color.
  final Color backgroundColor;

  /// The bar text style.
  final TextStyle textStyle;

  /// The day formatter.
  final DateFormatter dateFormatter;

  /// Creates a new day bar instance.
  DayBar({
    @required DateTime date,
    double height = 40,
    this.backgroundColor = const Color(0xFFEBEBEB),
    this.textStyle,
    this.dateFormatter = DefaultBuilders.defaultDateFormatter,
  })  : assert(date != null),
        assert(backgroundColor != null),
        assert(dateFormatter != null),
        date = DateTime(date.year, date.month, date.day),
        height = Math.max(0, height ?? 0);

  /// Creates a new day bar instance from a headers widget instance.
  DayBar.fromHeadersWidget({
    @required HeadersWidget parent,
    DateTime date,
  }) : this(
          date: date ?? DateTime.now(),
          height: parent.dayBarHeight,
          backgroundColor: parent.dayBarBackgroundColor ?? const Color(0xFFEBEBEB),
          textStyle: parent.dayBarTextStyle,
          dateFormatter: parent.dateFormatter,
        );

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        color: backgroundColor,
        child: Center(
          child: Text(
            dateFormatter(date.year, date.month, date.day),
            style: textStyle ??
                TextStyle(
                  color: Utils.overlapsDate(date) ? Colors.blue[800] : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      );
}

/// A column which is showing a day hours.
class HoursColumn extends StatelessWidget {
  /// The hour row height.
  final double hourRowHeight;

  /// The width.
  final double width;

  /// The background color.
  final Color backgroundColor;

  /// The text style.
  final TextStyle textStyle;

  /// The hour formatter.
  final HourFormatter hourFormatter;

  /// Creates a new hours column instance.
  HoursColumn({
    double hourRowHeight = 60,
    double width = 60,
    this.backgroundColor = Colors.white,
    this.textStyle = const TextStyle(color: Colors.black54),
    this.hourFormatter = DefaultBuilders.defaultHourFormatter,
  })  : assert(hourFormatter != null),
        this.hourRowHeight = Math.max(0, hourRowHeight ?? 0),
        this.width = Math.max(0, width ?? 0);

  /// Creates a new hours column instance from a headers widget instance.
  HoursColumn.fromHeadersWidget({
    @required HeadersWidget parent,
    @required double zoomFactor,
  }) : this(
          hourRowHeight: parent.hourRowHeight * zoomFactor,
          width: parent.hoursColumnWidth,
          backgroundColor: parent.hoursColumnBackgroundColor ?? Colors.white,
          textStyle: parent.hoursColumnTextStyle ?? const TextStyle(color: Colors.black54),
          hourFormatter: parent.hourFormatter,
        );

  @override
  Widget build(BuildContext context) => Container(
        height: 24 * hourRowHeight,
        width: width,
        color: backgroundColor,
        child: Stack(
          children: List.generate(
            23,
            (hour) => Positioned(
              top: (hour + 1) * hourRowHeight - ((textStyle?.fontSize ?? 14) / 2),
              left: 0,
              right: 0,
              child: Text(
                hourFormatter(hour + 1, 0),
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
}
