import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/controller.dart';
import 'package:flutter_week_view/src/day_view.dart';
import 'package:flutter_week_view/src/utils.dart';

/// A widget which is showing both headers and can be zoomed.
abstract class ZoomableHeadersWidget<C extends ZoomController> extends StatefulWidget {
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

  /// Whether the widget should automatically be placed in a scrollable widget.
  final bool inScrollableWidget;

  /// The initial visible hour.
  final int initialHour;

  /// The initial visible minute.
  final int initialMinute;

  /// Whether the widget should automatically scroll to the current time (hour and minute).
  final bool scrollToCurrentTime;

  /// Whether the user is able to pinch-to-zoom the widget.
  final bool userZoomable;

  /// The current day view controller.
  final C controller;

  /// Creates a new zoomable headers widget instance.
  ZoomableHeadersWidget({
    @required this.controller,
    this.dateFormatter = DefaultBuilders.defaultDateFormatter,
    this.hourFormatter = DefaultBuilders.defaultHourFormatter,
    this.dayBarTextStyle,
    double dayBarHeight = 40,
    this.dayBarBackgroundColor,
    this.hoursColumnTextStyle,
    double hoursColumnWidth = 60,
    this.hoursColumnBackgroundColor,
    double hourRowHeight = 60,
    @required this.inScrollableWidget,
    int initialHour,
    int initialMinute,
    @required this.scrollToCurrentTime,
    @required this.userZoomable,
  })  : assert(dateFormatter != null),
        assert(hourFormatter != null),
        dayBarHeight = math.max(0, dayBarHeight ?? 40),
        hoursColumnWidth = math.max(0, hoursColumnWidth ?? 60),
        hourRowHeight = math.max(0, hourRowHeight ?? 60),
        initialHour = math.min(23, math.max(0, initialHour ?? 0)),
        initialMinute = math.min(59, math.max(0, initialMinute ?? 0)),
        assert(inScrollableWidget != null),
        assert(scrollToCurrentTime != null),
        assert(userZoomable != null);

  /// Calculates the hour row height.
  double _calculateHourRowHeight([C controller]) => hourRowHeight * (controller ?? this.controller).zoomFactor;
}

/// An abstract widget state that shows both headers and can be zoomed.
abstract class ZoomableHeadersWidgetState<W extends ZoomableHeadersWidget<C>, C extends ZoomController> extends State<W> with ZoomControllerListener {
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
      widget.controller.zoomFactor = oldWidget.controller.zoomFactor;
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
      double maxPixels = calculateHeight(hourRowHeight) - widgetHeight + widget.dayBarHeight;

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

  /// Schedules a scroll to the default hour.
  void scheduleScrollToInitialHour() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToTime(widget.initialHour, widget.initialMinute));
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

  /// Checks whether the widget should scroll to current time.
  bool get shouldScrollToCurrentTime => widget.scrollToCurrentTime;

  /// Scrolls to current time.
  void scrollToCurrentTime() {
    if (mounted) {
      DateTime now = DateTime.now();
      scrollToTime(now.hour, now.minute);
    }
  }

  /// Scrolls to a given time if possible.
  void scrollToTime(int hour, int minute) {
    if (widget.inScrollableWidget) {
      double topOffset = calculateTopOffset(hour, minute);
      widget.controller.verticalScrollController.jumpTo(math.min(topOffset, widget.controller.verticalScrollController.position.maxScrollExtent));
    }
  }

  /// Returns whether this widget should be zoomable.
  bool get isZoomable => widget.userZoomable && widget.controller.zoomCoefficient > 0;

  /// Calculates the top offset of a given hour and a given minute.
  double calculateTopOffset(int hour, [int minute = 0, double hourRowHeight]) => (hour + (minute / 60)) * (hourRowHeight ?? this.hourRowHeight);

  /// Calculates the widget height.
  double calculateHeight([double hourRowHeight]) => calculateTopOffset(24, 0, hourRowHeight);
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
                  color: Utils.sameDay(date) ? Colors.blue[800] : Colors.black54,
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
        hourRowHeight = math.max(0, hourRowHeight ?? 0),
        width = math.max(0, width ?? 0);

  /// Creates a new hours column instance from a headers widget instance.
  HoursColumn.fromHeadersWidget({
    @required ZoomableHeadersWidget parent,
  }) : this(
          hourRowHeight: parent._calculateHourRowHeight(),
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
