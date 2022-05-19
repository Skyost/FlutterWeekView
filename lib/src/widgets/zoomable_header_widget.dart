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
typedef CurrentTimeIndicatorBuilder = Widget? Function(
    DayViewStyle dayViewStyle,
    TopOffsetCalculator topOffsetCalculator,
    double hoursColumnWidth,
    bool isRtl);

/// Allows to build the time displayed on the side border.
typedef HoursColumnTimeBuilder = Widget? Function(
    HoursColumnStyle dayViewStyle, HourMinute time);

/// Allows to build the background decoration below single time displayed on the side border.
typedef HoursColumnBackgroundBuilder = Decoration? Function(HourMinute time);

/// A widget which is showing both headers and can be zoomed.
abstract class ZoomableHeadersWidget<S extends ZoomableHeaderWidgetStyle,
    C extends ZoomController> extends StatefulWidget {
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

  /// The initial visible time. Defaults to the current hour of the day (if possible).
  final DateTime initialTime;

  /// Whether the user is able to pinch-to-zoom the widget.
  final bool userZoomable;

  /// The current time indicator builder.
  final CurrentTimeIndicatorBuilder? currentTimeIndicatorBuilder;

  /// Building method for building the time displayed on the side border.
  final HoursColumnTimeBuilder? hoursColumnTimeBuilder;

  /// Building method for building background decoration below single time displayed on the side border.
  final HoursColumnBackgroundBuilder? hoursColumnBackgroundBuilder;

  /// Triggered when the hours column has been tapped down.
  final HoursColumnTapCallback? onHoursColumnTappedDown;

  /// Triggered when the day bar has been tapped down.
  final DayBarTapCallback? onDayBarTappedDown;

  /// The current day view controller.
  final C controller;

  /// Whether the widget should be aligned from right to left.
  final bool isRTL;

  /// Creates a new zoomable headers widget instance.
  const ZoomableHeadersWidget({
    Key? key,
    required this.style,
    required this.hoursColumnStyle,
    required this.inScrollableWidget,
    required this.minimumTime,
    required this.maximumTime,
    required this.initialTime,
    required this.userZoomable,
    this.currentTimeIndicatorBuilder,
    this.onHoursColumnTappedDown,
    this.onDayBarTappedDown,
    required this.controller,
    this.hoursColumnTimeBuilder,
    this.hoursColumnBackgroundBuilder,
    required this.isRTL,
  }) : super(key: key);
}

/// An abstract widget state that shows both headers and can be zoomed.
abstract class ZoomableHeadersWidgetState<W extends ZoomableHeadersWidget>
    extends State<W> with ZoomControllerListener {
  /// The current hour row height.
  late double hourRowHeight;

  /// The vertical scroll controller.
  ScrollController? verticalScrollController;

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
      widget.controller
          .changeZoomFactor(oldWidget.controller.zoomFactor, notify: false);
    }

    hourRowHeight = _calculateHourRowHeight();
    oldWidget.controller.removeListener(this);
    widget.controller.addListener(this);
  }

  @override
  void onZoomStart(ZoomController controller, ScaleStartDetails details) {
    /// store current scroll position (vertical) and pinch focal point position (vertical) for future use in onZoomFactorChanged()
    if (verticalScrollController != null) {
      controller.contentOffset =
          (verticalScrollController!.offset + details.localFocalPoint.dy) /
              controller.zoomFactor;
    }
  }

  @override
  void onZoomFactorChanged(
      ZoomController controller, ScaleUpdateDetails details) {
    if (!mounted) {
      return;
    }

    double hourRowHeight = _calculateHourRowHeight(controller);
    double widgetHeight = (context.findRenderObject() as RenderBox).size.height;
    double maxPixels =
        calculateHeight(hourRowHeight) - widgetHeight + widget.style.headerSize;

    if (verticalScrollController != null) {
      verticalScrollController!.jumpTo(math.min(
          maxPixels,
          controller.contentOffset * controller.zoomFactor -
              details.localFocalPoint.dy));
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

  /// Schedules a scroll to the default hour.
  void scheduleScrollToInitialTime() {
    if (shouldScrollToInitialTime) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => scrollToInitialTime());
    }
  }

  /// Checks whether the widget should scroll to current time.
  bool get shouldScrollToInitialTime =>
      widget.minimumTime
          .atDate(widget.initialTime)
          .isBefore(widget.initialTime) &&
      widget.maximumTime.atDate(widget.initialTime).isAfter(widget.initialTime);

  /// Scrolls to the initial time.
  void scrollToInitialTime() {
    if (mounted &&
        verticalScrollController != null &&
        verticalScrollController!.hasClients) {
      double topOffset = calculateTopOffset(
          HourMinute.fromDateTime(dateTime: widget.initialTime));
      verticalScrollController!.jumpTo(math.min(
          topOffset, verticalScrollController!.position.maxScrollExtent));
    }
  }

  /// Returns whether this widget should be zoomable.
  bool get isZoomable =>
      widget.userZoomable && widget.controller.zoomCoefficient > 0;

  /// Calculates the top offset of a given time.
  double calculateTopOffset(HourMinute time,
          {HourMinute? minimumTime, double? hourRowHeight}) =>
      DefaultBuilders.defaultTopOffsetCalculator(time,
          minimumTime: minimumTime ?? widget.minimumTime,
          hourRowHeight: hourRowHeight ?? this.hourRowHeight);

  /// Calculates the widget height.
  double calculateHeight([double? hourRowHeight]) =>
      calculateTopOffset(widget.maximumTime, hourRowHeight: hourRowHeight);

  /// Calculates the hour row height.
  double _calculateHourRowHeight([ZoomController? controller]) =>
      currentDayViewStyle.hourRowHeight *
      (controller ?? widget.controller).zoomFactor;
}
