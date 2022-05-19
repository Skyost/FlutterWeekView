import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/controller/day_view.dart';
import 'package:flutter_week_view/src/event.dart';
import 'package:flutter_week_view/src/styles/day_bar.dart';
import 'package:flutter_week_view/src/styles/day_view.dart';
import 'package:flutter_week_view/src/styles/hours_column.dart';
import 'package:flutter_week_view/src/utils/builders.dart';
import 'package:flutter_week_view/src/utils/event_grid.dart';
import 'package:flutter_week_view/src/utils/hour_minute.dart';
import 'package:flutter_week_view/src/utils/scroll.dart';
import 'package:flutter_week_view/src/utils/utils.dart';
import 'package:flutter_week_view/src/widgets/day_bar.dart';
import 'package:flutter_week_view/src/widgets/hours_column.dart';
import 'package:flutter_week_view/src/widgets/zoomable_header_widget.dart';

/// A (scrollable) day view which is able to display events, zoom and un-zoom and more !
class DayView extends ZoomableHeadersWidget<DayViewStyle, DayViewController> {
  /// The events.
  final List<FlutterWeekViewEvent> events;

  /// The day view date.
  final DateTime date;

  /// The day bar style.
  final DayBarStyle dayBarStyle;

  /// Creates a new day view instance.
  DayView({
    List<FlutterWeekViewEvent>? events,
    required DateTime date,
    DayViewStyle? style,
    HoursColumnStyle? hoursColumnStyle,
    DayBarStyle? dayBarStyle,
    DayViewController? controller,
    bool? inScrollableWidget,
    bool? isRTL,
    HourMinute? minimumTime,
    HourMinute? maximumTime,
    HourMinute? initialTime,
    bool? userZoomable,
    CurrentTimeIndicatorBuilder? currentTimeIndicatorBuilder,
    HoursColumnTimeBuilder? hoursColumnTimeBuilder,
    HoursColumnBackgroundBuilder? hoursColumnBackgroundBuilder,
    HoursColumnTapCallback? onHoursColumnTappedDown,
    DayBarTapCallback? onDayBarTappedDown,
  })  : events = events ?? [],
        date = date.yearMonthDay,
        dayBarStyle = dayBarStyle ?? DayBarStyle.fromDate(date: date),
        super(
          style: style ?? DayViewStyle.fromDate(date: date),
          hoursColumnStyle: hoursColumnStyle ?? const HoursColumnStyle(),
          controller: controller ?? DayViewController(),
          inScrollableWidget: inScrollableWidget ?? true,
          isRTL: isRTL ?? false,
          minimumTime: minimumTime ?? HourMinute.min,
          maximumTime: maximumTime ?? HourMinute.max,
          initialTime: initialTime?.atDate(date) ??
              (Utils.sameDay(date) ? HourMinute.now() : const HourMinute())
                  .atDate(date),
          userZoomable: userZoomable ?? true,
          hoursColumnTimeBuilder: hoursColumnTimeBuilder ??
              DefaultBuilders.defaultHoursColumnTimeBuilder,
          hoursColumnBackgroundBuilder: hoursColumnBackgroundBuilder,
          currentTimeIndicatorBuilder: currentTimeIndicatorBuilder ??
              DefaultBuilders.defaultCurrentTimeIndicatorBuilder,
          onHoursColumnTappedDown: onHoursColumnTappedDown,
          onDayBarTappedDown: onDayBarTappedDown,
        );

  @override
  State<StatefulWidget> createState() => _DayViewState();
}

/// The day view state.
class _DayViewState extends ZoomableHeadersWidgetState<DayView> {
  /// Contains all events draw properties.
  final Map<FlutterWeekViewEvent, EventDrawProperties> eventsDrawProperties =
      HashMap();

  /// The flutter week view events.
  late List<FlutterWeekViewEvent> events;

  @override
  void initState() {
    super.initState();
    scheduleScrollToInitialTime();
    reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(createEventsDrawProperties);
      }
    });
  }

  @override
  void didUpdateWidget(DayView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.date != widget.date) {
      scheduleScrollToInitialTime();
    }

    reset();
    createEventsDrawProperties();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget = createMainWidget();
    if (widget.style.headerSize > 0 || widget.hoursColumnStyle.width > 0) {
      mainWidget = Stack(
        children: [
          mainWidget,
          Positioned(
            top: 0,
            left: widget.isRTL ? 0 : widget.hoursColumnStyle.width,
            right: widget.isRTL ? widget.hoursColumnStyle.width : 0,
            child: DayBar.fromHeadersWidgetState(
              parent: widget,
              date: widget.date,
              style: widget.dayBarStyle,
              width: double.infinity,
            ),
          ),
          Container(
            height: widget.style.headerSize,
            width: widget.hoursColumnStyle.width,
            color: widget.dayBarStyle.color,
          ),
        ],
      );
    }

    if (!isZoomable) {
      return mainWidget;
    }

    return GestureDetector(
      onScaleStart: widget.controller.scaleStart,
      onScaleUpdate: widget.controller.scaleUpdate,
      child: mainWidget,
    );
  }

  @override
  void onZoomFactorChanged(
      DayViewController controller, ScaleUpdateDetails details) {
    super.onZoomFactorChanged(controller, details);

    if (mounted) {
      setState(createEventsDrawProperties);
    }
  }

  @override
  DayViewStyle get currentDayViewStyle => widget.style;

  /// Creates the main widget, with a hours column and an events column.
  Widget createMainWidget() {
    List<Widget> children = eventsDrawProperties.entries
        .map((entry) => entry.value.createWidget(context, widget, entry.key))
        .toList();
    if (widget.hoursColumnStyle.width > 0) {
      children.add(Positioned(
        top: 0,
        left: widget.isRTL ? null : 0,
        child: HoursColumn.fromHeadersWidgetState(parent: this),
      ));
    }

    if (Utils.sameDay(widget.date) &&
        widget.minimumTime.atDate(widget.date).isBefore(DateTime.now()) &&
        widget.maximumTime.atDate(widget.date).isAfter(DateTime.now())) {
      Widget? currentTimeIndicator = (widget.currentTimeIndicatorBuilder ??
              DefaultBuilders.defaultCurrentTimeIndicatorBuilder)(widget.style,
          calculateTopOffset, widget.hoursColumnStyle.width, widget.isRTL);
      if (currentTimeIndicator != null) {
        children.add(currentTimeIndicator);
      }
    }

    Widget mainWidget = SizedBox(
      height: calculateHeight(),
      child: Stack(children: children..insert(0, createBackground())),
    );

    if (verticalScrollController != null) {
      mainWidget = NoGlowBehavior.noGlow(
        child: SingleChildScrollView(
          controller: verticalScrollController,
          child: mainWidget,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: widget.style.headerSize),
      child: mainWidget,
    );
  }

  /// Creates the background widgets that should be added to a stack.
  Widget createBackground() => Positioned.fill(
        child: CustomPaint(
          painter: widget.style.createBackgroundPainter(
            dayView: widget,
            topOffsetCalculator: calculateTopOffset,
          ),
        ),
      );

  /// Resets the events positioning.
  void reset() {
    eventsDrawProperties.clear();
    events = List.of(widget.events)..sort();
  }

  /// Creates the events draw properties and add them to the current list.
  void createEventsDrawProperties() {
    EventGrid eventsGrid = EventGrid();
    for (FlutterWeekViewEvent event in List.of(events)) {
      EventDrawProperties drawProperties = eventsDrawProperties[event] ??
          EventDrawProperties(widget, event, widget.isRTL);
      if (!drawProperties.shouldDraw) {
        events.remove(event);
        continue;
      }

      drawProperties.calculateTopAndHeight(calculateTopOffset);
      if (drawProperties.left == null || drawProperties.width == null) {
        eventsGrid.add(drawProperties);
      }

      eventsDrawProperties[event] = drawProperties;
    }

    if (eventsGrid.drawPropertiesList.isNotEmpty) {
      double eventsColumnWidth =
          (context.findRenderObject() as RenderBox).size.width -
              widget.hoursColumnStyle.width;
      eventsGrid.processEvents(
          widget.hoursColumnStyle.width, eventsColumnWidth);
    }
  }
}
