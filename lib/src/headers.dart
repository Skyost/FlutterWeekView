import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/controller.dart';
import 'package:flutter_week_view/src/hour_minute.dart';
import 'package:flutter_week_view/src/style.dart';
import 'package:flutter_week_view/src/utils.dart';

/// Allows to calculate a top offset from a given hour.
typedef TopOffsetCalculator = double Function(HourMinute time);

/// Triggered when the hours column has been tapped down.
typedef HoursColumnTappedDownCallback = Function(HourMinute time);

/// A widget which is showing both headers and can be zoomed.
abstract class ZoomableHeadersWidget<S extends ZoomableHeaderWidgetStyle, C extends ZoomController> extends StatefulWidget {
  /// The widget style.
  final S style;

  /// The hours column style.
  final HoursColumnStyle hoursColumnStyle;

  /// Whether the widget should automatically be placed in a scrollable widget.
  final bool inScrollableWidget;

  /// The minimum time to display.
  final HourMinute minimumTime;

  /// The maximum time to display.
  final HourMinute maximumTime;

  /// The initial visible time. If this is set, [scrollToCurrentTime] should be false, since
  /// that takes priority over [initialTime].
  final HourMinute initialTime;

  /// Whether the widget should automatically scroll to the current time (hour and minute). This
  /// takes priority over [initialTime].
  final bool scrollToCurrentTime;

  /// Whether the user is able to pinch-to-zoom the widget.
  final bool userZoomable;

  /// Triggered when the hours column has been tapped down.
  final HoursColumnTappedDownCallback onHoursColumnTappedDown;

  /// The current day view controller.
  final C controller;

  /// Creates a new zoomable headers widget instance.
  const ZoomableHeadersWidget({
    @required this.style,
    HoursColumnStyle hoursColumnStyle,
    @required this.inScrollableWidget,
    this.minimumTime = HourMinute.MIN,
    this.maximumTime = HourMinute.MAX,
    this.initialTime = HourMinute.MIN,
    @required this.scrollToCurrentTime,
    @required this.userZoomable,
    this.onHoursColumnTappedDown,
    @required this.controller,
  })  : hoursColumnStyle = hoursColumnStyle ?? const HoursColumnStyle(),
        assert(style != null),
        assert(minimumTime != null),
        assert(maximumTime != null),
        assert(minimumTime < maximumTime),
        assert(initialTime != null),
        assert(inScrollableWidget != null),
        assert(scrollToCurrentTime != null),
        assert(userZoomable != null);
}

/// An abstract widget state that shows both headers and can be zoomed.
abstract class ZoomableHeadersWidgetState<W extends ZoomableHeadersWidget> extends State<W> with ZoomControllerListener {
  /// The current hour row height.
  double hourRowHeight;

  /// The vertical scroll controller.
  ScrollController verticalScrollController;

  @override
  void initState() {
    super.initState();
    hourRowHeight = _calculateHourRowHeight();
    widget.controller.addListener(this);

    if (widget.inScrollableWidget) {
      verticalScrollController = ScrollController();
    }
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller.zoomFactor != oldWidget.controller.zoomFactor) {
      widget.controller.changeZoomFactor(oldWidget.controller.zoomFactor, notify: false);
    }

    hourRowHeight = _calculateHourRowHeight();
    oldWidget.controller.removeListener(this);
    widget.controller.addListener(this);
  }

  @override
  void onZoomFactorChanged(ZoomController controller, ScaleUpdateDetails details) {
    if (!mounted) {
      return;
    }

    double hourRowHeight = _calculateHourRowHeight(controller);
    if (verticalScrollController != null) {
      double widgetHeight = (context.findRenderObject() as RenderBox).size.height;
      double maxPixels = calculateHeight(hourRowHeight) - widgetHeight + widget.style.headerSize;

      if (hourRowHeight < this.hourRowHeight && verticalScrollController.position.pixels > maxPixels) {
        verticalScrollController.jumpTo(maxPixels);
      } else {
        verticalScrollController.jumpTo(math.min(maxPixels, details.localFocalPoint.dy));
      }
    }

    setState(() {
      this.hourRowHeight = hourRowHeight;
    });
  }

  @override
  void dispose() {
    widget.controller.dispose();
    verticalScrollController?.dispose();
    super.dispose();
  }

  /// Returns the current day view style.
  DayViewStyle get currentDayViewStyle;

  /// Schedules both scroll if needed.
  void scheduleScrolls() {
    if (!scheduleScrollToCurrentTimeIfNeeded()) {
      scheduleScrollToInitialHour();
    }
  }

  /// Schedules a scroll to the current time if needed.
  bool scheduleScrollToCurrentTimeIfNeeded() {
    if (shouldScrollToCurrentTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToCurrentTime());
      return true;
    }
    return false;
  }

  /// Schedules a scroll to the default hour.
  void scheduleScrollToInitialHour() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToTime(widget.initialTime));
    }
  }

  /// Checks whether the widget should scroll to current time.
  bool get shouldScrollToCurrentTime => widget.scrollToCurrentTime;

  /// Scrolls to current time.
  void scrollToCurrentTime() {
    if (mounted) {
      scrollToTime(HourMinute.now());
    }
  }

  /// Scrolls to a given time if possible.
  void scrollToTime(HourMinute time) {
    if (verticalScrollController != null) {
      double topOffset = calculateTopOffset(time);
      verticalScrollController.jumpTo(math.min(topOffset, verticalScrollController.position.maxScrollExtent));
    }
  }

  /// Returns whether this widget should be zoomable.
  bool get isZoomable => widget.userZoomable && widget.controller.zoomCoefficient > 0;

  /// Calculates the top offset of a given time.
  double calculateTopOffset(HourMinute time, {HourMinute minimumTime, double hourRowHeight}) => DefaultBuilders.defaultTopOffsetCalculator(time, minimumTime: minimumTime ?? widget.minimumTime, hourRowHeight: hourRowHeight ?? this.hourRowHeight);

  /// Calculates the widget height.
  double calculateHeight([double hourRowHeight]) => calculateTopOffset(widget.maximumTime, hourRowHeight: hourRowHeight);

  /// Calculates the hour row height.
  double _calculateHourRowHeight([ZoomController controller]) => currentDayViewStyle.hourRowHeight * (controller ?? widget.controller).zoomFactor;
}

/// A bar which is showing a day.
class DayBar extends StatelessWidget {
  /// The date.
  final DateTime date;

  /// The widget style.
  final DayBarStyle style;

  /// The widget height.
  final double height;

  /// The width width.
  final double width;

  /// The hours column width.
  final double hoursColumnWidth;

  /// Creates a new day bar instance.
  DayBar({
    @required DateTime date,
    @required this.style,
    this.height,
    this.width,
    this.hoursColumnWidth,
  })  : assert(date != null),
        assert(style != null),
        date = DateTime(date.year, date.month, date.day);

  @override
  Widget build(BuildContext context) => Container(
        padding: hoursColumnWidth == null ? null : EdgeInsets.only(left: hoursColumnWidth),
        height: height,
        width: width,
        color: style.decoration == null ? style.color : null,
        decoration: style.decoration,
        alignment: style.textAlignment,
        child: Text(
          style.dateFormatter(date.year, date.month, date.day),
          style: style.textStyle,
        ),
      );
}

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
  final HoursColumnTappedDownCallback onHoursColumnTappedDown;

  /// The times to display on the side border.
  final List<HourMinute> _sideTimes;

  /// Creates a new hours column instance.
  HoursColumn({
    this.minimumTime = HourMinute.MIN,
    this.maximumTime = HourMinute.MAX,
    TopOffsetCalculator topOffsetCalculator,
    HoursColumnStyle style,
    this.onHoursColumnTappedDown,
  })  : assert(minimumTime != null),
        assert(maximumTime != null),
        assert(minimumTime < maximumTime),
        topOffsetCalculator = topOffsetCalculator ?? DefaultBuilders.defaultTopOffsetCalculator,
        style = style ?? const HoursColumnStyle(),
        _sideTimes = getSideTimes(minimumTime, maximumTime);

  /// Creates a new hours column instance from a headers widget instance.
  HoursColumn.fromHeadersWidgetState({
    @required ZoomableHeadersWidgetState parent,
  }) : this(
          minimumTime: parent.widget.minimumTime,
          maximumTime: parent.widget.maximumTime,
          topOffsetCalculator: parent.calculateTopOffset,
          style: parent.widget.hoursColumnStyle,
          onHoursColumnTappedDown: parent.widget.onHoursColumnTappedDown,
        );

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      height: topOffsetCalculator(maximumTime),
      width: style.width,
      color: style.decoration == null ? style.color : null,
      decoration: style.decoration,
      child: Stack(
        children: _sideTimes
            .map(
              (time) => Positioned(
                top: topOffsetCalculator(time) - ((style.textStyle?.fontSize ?? 14) / 2),
                left: 0,
                right: 0,
                child: Align(
                  alignment: style.textAlignment,
                  child: Text(
                    style.timeFormatter(time),
                    style: style.textStyle,
                  ),
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
        var hourRowHeight = topOffsetCalculator(minimumTime.add(const HourMinute(hour: 1)));
        double hourMinutesInHour = details.localPosition.dy / hourRowHeight;

        int hour = hourMinutesInHour.floor();
        int minute = ((hourMinutesInHour - hour) * 60).round();
        onHoursColumnTappedDown(minimumTime.add(HourMinute(hour: hour, minute: minute)));
      },
      child: child,
    );
  }

  /// Creates the side times.
  static List<HourMinute> getSideTimes(HourMinute minimumTime, HourMinute maximumTime) {
    List<HourMinute> sideTimes = [];
    HourMinute currentHour = HourMinute(hour: minimumTime.hour + 1);
    while (currentHour < maximumTime) {
      sideTimes.add(currentHour);
      currentHour = currentHour.add(const HourMinute(hour: 1));
    }
    return sideTimes;
  }
}
