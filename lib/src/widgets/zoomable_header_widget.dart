import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/controller/zoom_controller.dart';
import 'package:flutter_week_view/src/styles/day_view.dart';
import 'package:flutter_week_view/src/styles/hours_column.dart';
import 'package:flutter_week_view/src/styles/zoomable_header_widget.dart';
import 'package:flutter_week_view/src/utils/builders.dart';
import 'package:flutter_week_view/src/utils/hour_minute.dart';

/// Allows to calculate a top offset from a given hour.
typedef TopOffsetCalculator = double Function(HourMinute time);

/// Triggered when the hours column has been tapped down.
typedef HoursColumnTapCallback = Function(HourMinute time);

/// Triggered when the day bar has been tapped down.
typedef DayBarTapCallback = Function(DateTime date);

/// Allows to build the current time indicator (rule and circle).
typedef CurrentTimeIndicatorBuilder = Function(DayViewStyle style, TopOffsetCalculator topOffsetCalculator);

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
  final HoursColumnTapCallback onHoursColumnTappedDown;

  /// Triggered when the day bar has been tapped down.
  final DayBarTapCallback onDayBarTappedDown;

  /// The current day view controller.
  final C controller;

  /// Creates a new zoomable headers widget instance.
  const ZoomableHeadersWidget({
    @required this.style,
    @required this.hoursColumnStyle,
    @required this.inScrollableWidget,
    @required this.minimumTime,
    @required this.maximumTime,
    @required this.initialTime,
    @required this.scrollToCurrentTime,
    @required this.userZoomable,
    this.onHoursColumnTappedDown,
    this.onDayBarTappedDown,
    @required this.controller,
  })  : assert(style != null),
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
