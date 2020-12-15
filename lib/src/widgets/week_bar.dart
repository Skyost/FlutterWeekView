import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/styles/day_bar.dart';
import 'package:flutter_week_view/src/utils/utils.dart';
import 'package:flutter_week_view/src/widgets/zoomable_header_widget.dart';

const weeks = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

/// A bar which is showing a week.
class WeekBar extends StatelessWidget {
  /// The date.
  // final DateTime date;

  /// The widget style.
  final DayBarStyle style;

  /// The widget height.
  final double height;

  /// The width width.
  final double width;

  /// Triggered when the day bar has been tapped down.
  final DayBarTapCallback onDayBarTappedDown;

  /// Creates a new day bar instance.
  WeekBar({
    // @required DateTime date,
    @required this.style,
    this.height,
    this.width,
    this.onDayBarTappedDown,
  }) : assert(style != null);
  // date = date.yearMonthDay;

  /// Creates a new day bar instance from a headers widget instance.
  WeekBar.fromHeadersWidgetState({
    @required ZoomableHeadersWidget parent,
    @required DayBarStyle style,
    double width,
  }) : this(
          style: style,
          height: parent.style.headerSize,
          width: width,
          onDayBarTappedDown: parent.onDayBarTappedDown,
        );

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    weeks.forEach((element) {
      children.add(
        Expanded(
          flex: 1,
          child: Container(
            height: height,
            color: style.decoration == null ? style.color : null,
            decoration: style.decoration,
            alignment: style.textAlignment,
            child: Text(
              element,
              style: style.textStyle,
            ),
          ),
        ),
      );
    });

    return Container(
      height: height,
      color: style.decoration == null ? style.color : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
