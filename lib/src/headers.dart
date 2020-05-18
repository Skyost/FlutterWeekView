import 'dart:math' as math;

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

  /// Whether the widget should automatically be placed in a scrollable widget.
  final bool inScrollableWidget;

  /// The minimum time to display.
  final HourMinute minimumTime;

  /// The maximum time to display.
  final HourMinute maximumTime;

  /// The initial visible time.
  final HourMinute initialTime;

  /// Whether the widget should automatically scroll to the current time (hour and minute).
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
    @required this.inScrollableWidget,
    this.minimumTime = HourMinute.MIN,
    this.maximumTime = HourMinute.MAX,
    this.initialTime = HourMinute.MIN,
    @required this.scrollToCurrentTime,
    @required this.userZoomable,
    this.onHoursColumnTappedDown,
    @required this.controller,
  })  : assert(minimumTime != null),
        assert(maximumTime != null),
        assert(minimumTime < maximumTime),
        assert(initialTime != null),
        assert(inScrollableWidget != null),
        assert(scrollToCurrentTime != null),
        assert(userZoomable != null);

  /// Calculates the hour row height.
  double _calculateHourRowHeight([C controller]) => style.hourRowHeight * (controller ?? this.controller).zoomFactor;
}

/// An abstract widget state that shows both headers and can be zoomed.
abstract class ZoomableHeadersWidgetState<W extends ZoomableHeadersWidget> extends State<W> with ZoomControllerListener {
  /// The current hour row height.
  double hourRowHeight;

  @override
  void initState() {
    super.initState();
    hourRowHeight = widget._calculateHourRowHeight();
    widget.controller.addListener(this);
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller.zoomFactor != oldWidget.controller.zoomFactor) {
      widget.controller.changeZoomFactor(oldWidget.controller.zoomFactor, notify: false);
    }

    hourRowHeight = widget._calculateHourRowHeight();
    oldWidget.controller.removeListener(this);
    widget.controller.addListener(this);
  }

  @override
  void onZoomFactorChanged(ZoomController controller, ScaleUpdateDetails details) {
    if (!mounted) {
      return;
    }

    double hourRowHeight = widget._calculateHourRowHeight(controller);

    if (widget.inScrollableWidget) {
      double widgetHeight = (context.findRenderObject() as RenderBox).size.height;
      double maxPixels = calculateHeight(hourRowHeight) - widgetHeight + widget.style.dayBarHeight;

      if (hourRowHeight < this.hourRowHeight && controller.verticalScrollController.position.pixels > maxPixels) {
        controller.verticalScrollController.jumpTo(maxPixels);
      } else {
        controller.verticalScrollController.jumpTo(math.min(maxPixels, details.localFocalPoint.dy));
      }
    }

    setState(() {
      this.hourRowHeight = hourRowHeight;
    });
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

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
    if (widget.inScrollableWidget) {
      double topOffset = calculateTopOffset(time);
      widget.controller.verticalScrollController.jumpTo(math.min(topOffset, widget.controller.verticalScrollController.position.maxScrollExtent));
    }
  }

  /// Returns whether this widget should be zoomable.
  bool get isZoomable => widget.userZoomable && widget.controller.zoomCoefficient > 0;

  /// Calculates the top offset of a given time.
  double calculateTopOffset(HourMinute time, {HourMinute minimumTime, double hourRowHeight}) => DefaultBuilders.defaultTopOffsetCalculator(time, minimumTime: minimumTime ?? widget.minimumTime, hourRowHeight: hourRowHeight ?? this.hourRowHeight);

  /// Calculates the widget height.
  double calculateHeight([double hourRowHeight]) => calculateTopOffset(widget.maximumTime, hourRowHeight: hourRowHeight);
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
        height = math.max(0, height ?? 0);

  /// Creates a new day bar instance from a headers widget instance.
  DayBar.fromHeadersWidget({
    @required ZoomableHeadersWidget parent,
    DateTime date,
  }) : this(
          date: date ?? DateTime.now(),
          height: parent.style.dayBarHeight,
          backgroundColor: parent.style.dayBarBackgroundColor ?? const Color(0xFFEBEBEB),
          textStyle: parent.style.dayBarTextStyle,
          dateFormatter: parent.style.dateFormatter,
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
                  color: Utils.sameDay(date) ? Colors.blue[800] : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
          ),
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

  /// The width.
  final double width;

  /// The background color.
  final Color backgroundColor;

  /// The text style.
  final TextStyle textStyle;

  /// The hour formatter.
  final TimeFormatter timeFormatter;

  /// Triggered when the hours column has been tapped down.
  final HoursColumnTappedDownCallback onHoursColumnTappedDown;

  /// The times to display on the side border.
  final List<HourMinute> _sideTimes;

  /// Creates a new hours column instance.
  HoursColumn({
    this.minimumTime = HourMinute.MIN,
    this.maximumTime = HourMinute.MAX,
    TopOffsetCalculator topOffsetCalculator,
    double width = 60,
    this.backgroundColor = Colors.white,
    this.textStyle = const TextStyle(color: Colors.black54),
    this.timeFormatter = DefaultBuilders.defaultTimeFormatter,
    this.onHoursColumnTappedDown,
  })  : assert(minimumTime != null),
        assert(maximumTime != null),
        assert(minimumTime < maximumTime),
        topOffsetCalculator = topOffsetCalculator ?? DefaultBuilders.defaultTopOffsetCalculator,
        width = math.max(0, width ?? 0),
        assert(timeFormatter != null),
        _sideTimes = getSideTimes(minimumTime, maximumTime);

  /// Creates a new hours column instance from a headers widget instance.
  HoursColumn.fromHeadersWidgetState({
    @required ZoomableHeadersWidgetState parent,
  }) : this(
          minimumTime: parent.widget.minimumTime,
          maximumTime: parent.widget.maximumTime,
          topOffsetCalculator: parent.calculateTopOffset,
          width: parent.widget.style.hoursColumnWidth,
          backgroundColor: parent.widget.style.hoursColumnBackgroundColor ?? Colors.white,
          textStyle: parent.widget.style.hoursColumnTextStyle ?? const TextStyle(color: Colors.black54),
          timeFormatter: parent.widget.style.timeFormatter,
          onHoursColumnTappedDown: parent.widget.onHoursColumnTappedDown,
        );

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      height: topOffsetCalculator(maximumTime),
      width: width,
      color: backgroundColor,
      child: Stack(
        children: _sideTimes
            .map(
              (time) => Positioned(
                top: topOffsetCalculator(time) - ((textStyle?.fontSize ?? 14) / 2),
                left: 0,
                right: 0,
                child: Text(
                  timeFormatter(time),
                  style: textStyle,
                  textAlign: TextAlign.center,
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
