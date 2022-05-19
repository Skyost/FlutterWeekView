import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/styles/hours_column.dart';
import 'package:flutter_week_view/src/utils/builders.dart';
import 'package:flutter_week_view/src/utils/hour_minute.dart';
import 'package:flutter_week_view/src/widgets/zoomable_header_widget.dart';

/// A column which is showing a day hours.
class HoursColumn extends StatelessWidget {
  /// The minimum time to display.
  final HourMinute minimumTime;

  /// The maximum time to display.
  final HourMinute maximumTime;

  /// The top offset calculator.
  final TopOffsetCalculator topOffsetCalculator;

  /// The widget style.
  final HoursColumnStyle style;

  /// Triggered when the hours column has been tapped down.
  final HoursColumnTapCallback? onHoursColumnTappedDown;

  /// The times to display on the side border.
  final List<HourMinute> _sideTimes;

  /// Building method for building the time displayed on the side border.
  final HoursColumnTimeBuilder hoursColumnTimeBuilder;

  /// Building method for building background decoration below single time displayed on the side border.
  final HoursColumnBackgroundBuilder? hoursColumnBackgroundBuilder;

  /// Creates a new hours column instance.
  HoursColumn({
    Key? key,
    this.minimumTime = HourMinute.min,
    this.maximumTime = HourMinute.max,
    TopOffsetCalculator? topOffsetCalculator,
    this.style = const HoursColumnStyle(),
    this.onHoursColumnTappedDown,
    HoursColumnTimeBuilder? hoursColumnTimeBuilder,
    this.hoursColumnBackgroundBuilder,
  })  : assert(minimumTime < maximumTime),
        topOffsetCalculator =
            topOffsetCalculator ?? DefaultBuilders.defaultTopOffsetCalculator,
        hoursColumnTimeBuilder = hoursColumnTimeBuilder ??
            DefaultBuilders.defaultHoursColumnTimeBuilder,
        _sideTimes = getSideTimes(minimumTime, maximumTime, style.interval),
        super(key: key);

  /// Creates a new h, super(key: key)ours column instance from a headers widget instance.
  HoursColumn.fromHeadersWidgetState({
    Key? key,
    required ZoomableHeadersWidgetState parent,
  }) : this(
          key: key,
          minimumTime: parent.widget.minimumTime,
          maximumTime: parent.widget.maximumTime,
          topOffsetCalculator: parent.calculateTopOffset,
          style: parent.widget.hoursColumnStyle,
          onHoursColumnTappedDown: parent.widget.onHoursColumnTappedDown,
          hoursColumnTimeBuilder: parent.widget.hoursColumnTimeBuilder,
          hoursColumnBackgroundBuilder:
              parent.widget.hoursColumnBackgroundBuilder,
        );

  @override
  Widget build(BuildContext context) {
    final singleHourSize =
        topOffsetCalculator(maximumTime) / (maximumTime.hour);
    final Widget background;
    if (hoursColumnBackgroundBuilder != null) {
      background = SizedBox(
        height: topOffsetCalculator(maximumTime),
        width: style.width,
        child: Padding(
          padding: EdgeInsets.only(top: singleHourSize),
          child: Column(
            children: _sideTimes
                .map(
                  (time) => Container(
                    decoration: hoursColumnBackgroundBuilder!(time),
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
                    top: topOffsetCalculator(time) -
                        ((style.textStyle.fontSize ?? 14) / 2),
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: style.textAlignment,
                      child: hoursColumnTimeBuilder(style, time),
                    ),
                  ),
                )
                .toList(),
      ),
    );

    if (onHoursColumnTappedDown == null) {
      return child;
    }

    return GestureDetector(
      onTapDown: (details) {
        var hourRowHeight =
            topOffsetCalculator(minimumTime.add(const HourMinute(hour: 1)));
        double hourMinutesInHour = details.localPosition.dy / hourRowHeight;

        int hour = hourMinutesInHour.floor();
        int minute = ((hourMinutesInHour - hour) * 60).round();
        onHoursColumnTappedDown!(
            minimumTime.add(HourMinute(hour: hour, minute: minute)));
      },
      child: child,
    );
  }

  /// Creates the side times.
  static List<HourMinute> getSideTimes(
      HourMinute minimumTime, HourMinute maximumTime, Duration interval) {
    List<HourMinute> sideTimes = [];
    HourMinute currentHour = HourMinute(hour: minimumTime.hour + 1);
    while (currentHour < maximumTime) {
      sideTimes.add(currentHour);
      currentHour =
          currentHour.add(HourMinute.fromDuration(duration: interval));
    }
    return sideTimes;
  }
}
