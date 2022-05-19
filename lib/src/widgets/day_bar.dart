import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/styles/day_bar.dart';
import 'package:flutter_week_view/src/utils/utils.dart';
import 'package:flutter_week_view/src/widgets/zoomable_header_widget.dart';

/// A bar which is showing a day.
class DayBar extends StatelessWidget {
  /// The date.
  final DateTime date;

  /// The widget style.
  final DayBarStyle style;

  /// The widget height.
  final double? height;

  /// The width width.
  final double? width;

  /// Triggered when the day bar has been tapped down.
  final DayBarTapCallback? onDayBarTappedDown;

  /// Creates a new day bar instance.
  DayBar({
    Key? key,
    required DateTime date,
    required this.style,
    this.height,
    this.width,
    this.onDayBarTappedDown,
  })  : date = date.yearMonthDay,
        super(key: key);

  /// Creates a new day bar instance from a headers widget instance.
  DayBar.fromHeadersWidgetState({
    Key? key,
    required ZoomableHeadersWidget parent,
    required DateTime date,
    required DayBarStyle style,
    double? width,
  }) : this(
          key: key,
          date: date,
          style: style,
          height: parent.style.headerSize,
          width: width,
          onDayBarTappedDown: parent.onDayBarTappedDown,
        );

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (details) => (onDayBarTappedDown ?? (date) {})(date),
        child: Container(
          height: height,
          width: width,
          color: style.decoration == null ? style.color : null,
          decoration: style.decoration,
          alignment: style.textAlignment,
          child: Text(
            style.dateFormatter(date.year, date.month, date.day),
            style: style.textStyle,
          ),
        ),
      );
}
