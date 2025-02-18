import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/styles/hours_column.dart';
import 'package:flutter_week_view/src/utils/builders.dart';
import 'package:flutter_week_view/src/utils/time_of_day.dart';
import 'package:flutter_week_view/src/widgets/zoomable_header_widget.dart';

/// A column which is showing a day hours.
class HourColumn extends StatelessWidget {
  /// The minimum time to display.
  final TimeOfDay minimumTime;

  /// The maximum time to display.
  final TimeOfDay maximumTime;

  /// The top offset calculator.
  final TopOffsetCalculator topOffsetCalculator;

  /// The widget style.
  final HourColumnStyle style;

  /// Triggered when the hour column has been tapped down.
  final HourColumnTapCallback? onHourColumnTappedDown;

  /// The times to display on the side border.
  final List<TimeOfDay> _sideTimes;

  /// Building method for building the time displayed on the side border.
  final HourColumnTimeBuilder hourColumnTimeBuilder;

  /// Building method for building background decoration below single time displayed on the side border.
  final HourColumnBackgroundBuilder? hourColumnBackgroundBuilder;

  /// Creates a new hour column instance.
  HourColumn({
    super.key,
    this.minimumTime = TimeOfDayUtils.min,
    this.maximumTime = TimeOfDayUtils.max,
    TopOffsetCalculator? topOffsetCalculator,
    this.style = const HourColumnStyle(),
    this.onHourColumnTappedDown,
    HourColumnTimeBuilder? hourColumnTimeBuilder,
    this.hourColumnBackgroundBuilder,
  })  : assert(minimumTime.isBefore(maximumTime)),
        topOffsetCalculator = topOffsetCalculator ?? DefaultBuilders.defaultTopOffsetCalculator,
        hourColumnTimeBuilder = hourColumnTimeBuilder ?? DefaultBuilders.defaultHourColumnTimeBuilder,
        _sideTimes = getSideTimes(minimumTime, maximumTime, style.interval);

  /// Creates a new h, super(key: key)ours column instance from a headers widget instance.
  HourColumn.fromHeadersWidgetState({
    Key? key,
    required ZoomableHeadersWidgetState parent,
  }) : this(
          key: key,
          minimumTime: parent.widget.minimumTime,
          maximumTime: parent.widget.maximumTime,
          topOffsetCalculator: parent.calculateTopOffset,
          style: parent.widget.hourColumnStyle,
          onHourColumnTappedDown: parent.widget.onHourColumnTappedDown,
          hourColumnTimeBuilder: parent.widget.hourColumnTimeBuilder,
          hourColumnBackgroundBuilder: parent.widget.hourColumnBackgroundBuilder,
        );

  @override
  Widget build(BuildContext context) {
    double singleHourSize = topOffsetCalculator(maximumTime) / (maximumTime.hour);
    Widget background;
    if (hourColumnBackgroundBuilder != null) {
      background = SizedBox(
        height: topOffsetCalculator(maximumTime),
        width: style.width,
        child: Padding(
          padding: EdgeInsets.only(top: singleHourSize),
          child: Column(
            children: _sideTimes
                .map(
                  (time) => Container(
                    decoration: hourColumnBackgroundBuilder!(time),
                    height: singleHourSize,
                  ),
                )
                .toList(),
          ),
        ),
      );
    } else {
      background = const SizedBox.shrink();
    }

    Widget child = Container(
      height: topOffsetCalculator(maximumTime),
      width: style.width,
      color: style.decoration == null ? style.color : null,
      decoration: style.decoration,
      child: Stack(
        children: <Widget>[background] +
            _sideTimes
                .map(
                  (time) => Positioned(
                    top: topOffsetCalculator(time) - ((style.textStyle.fontSize ?? 14) / 2),
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: style.textAlignment,
                      child: hourColumnTimeBuilder(style, time),
                    ),
                  ),
                )
                .toList(),
      ),
    );

    if (onHourColumnTappedDown == null) {
      return child;
    }

    return GestureDetector(
      onTapDown: (details) {
        var hourRowHeight = topOffsetCalculator(minimumTime.add(const Duration(hours: 1)));
        double hourMinutesInHour = details.localPosition.dy / hourRowHeight;

        int hour = hourMinutesInHour.floor();
        int minute = ((hourMinutesInHour - hour) * 60).round();
        onHourColumnTappedDown!(minimumTime.add(Duration(hours: hour, minutes: minute)));
      },
      child: child,
    );
  }

  /// Creates the side times.
  static List<TimeOfDay> getSideTimes(TimeOfDay minimumTime, TimeOfDay maximumTime, Duration interval) {
    List<TimeOfDay> sideTimes = [];
    TimeOfDay currentHour = TimeOfDay(hour: minimumTime.hour + 1, minute: 0);
    while (currentHour.isBefore(maximumTime)) {
      sideTimes.add(currentHour);
      currentHour = currentHour.add(interval);
    }
    return sideTimes;
  }
}
