import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/controller/day_view.dart';
import 'package:flutter_week_view/src/event.dart';
import 'package:flutter_week_view/src/styles/day_bar.dart';
import 'package:flutter_week_view/src/styles/day_view.dart';
import 'package:flutter_week_view/src/styles/hours_column.dart';
import 'package:flutter_week_view/src/utils/builders.dart';
import 'package:flutter_week_view/src/utils/callback_helpers.dart';
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
    super.key,
    this.events = const [],
    required DateTime date,
    DayViewStyle? style,
    super.hoursColumnStyle = const HoursColumnStyle(),
    DayBarStyle? dayBarStyle,
    DayViewController? controller,
    super.inScrollableWidget,
    super.isRTL,
    super.minimumTime,
    super.maximumTime,
    HourMinute? initialTime,
    super.userZoomable,
    super.currentTimeIndicatorBuilder,
    super.hoursColumnTimeBuilder,
    super.hoursColumnBackgroundBuilder,
    super.onHoursColumnTappedDown,
    super.onDayBarTappedDown,
    super.onBackgroundTappedDown,
    super.dragAndDropOptions,
    super.resizeEventOptions,
  })  : date = date.yearMonthDay,
        dayBarStyle = dayBarStyle ?? DayBarStyle.fromDate(date: date),
        super(
          style: style ?? DayViewStyle.fromDate(date: date),
          controller: controller ?? DayViewController(),
          initialTime: initialTime?.atDate(date) ?? (Utils.sameDay(date) ? HourMinute.now() : const HourMinute()).atDate(date),
        );

  @override
  State<StatefulWidget> createState() => _DayViewState();
}

/// The day view state.
class _DayViewState extends ZoomableHeadersWidgetState<DayView> {
  /// Contains all events draw properties.
  final Map<FlutterWeekViewEvent, EventDrawProperties> eventsDrawProperties = HashMap();

  /// The flutter week view events.
  late List<FlutterWeekViewEvent> events;

  /// These two variables control the resizing of events.
  ///
  /// Since we only receive the resize offset per update, we use this variable to
  /// accumulate the full resize offset since the beginning of the resize action.
  late double accumulatedResizeOffset;

  /// Stores the original end time of the event being resized. This is so that
  /// we can restore the original event before the callback.
  late DateTime originalResizeEventEnd;

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
    Widget mainWidget;

    if (widget.dragAndDropOptions == null) {
      mainWidget = createMainWidget();
    } else {
      mainWidget = DragTarget<FlutterWeekViewEvent>(
        builder: (_, __, ___) => createMainWidget(),
        onAcceptWithDetails: (details) {
          // Drag details contains the global position of the drag event. First,
          // we convert it to a local position on the widget.
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          Offset localOffset = renderBox.globalToLocal(details.offset);

          // After, we need to correct for scrolling. For example, if the widget
          // is scrolled such that "5:00" is the first hour shown, a drag-and-drop
          // at the first row of pixels still gives localOffset.dy = 0, so we
          // add the scroll offset to get the proper value for "5:00". We also
          // adjust for the header.
          Offset correctedOffset = Offset(localOffset.dx, localOffset.dy + (verticalScrollController?.offset ?? 0) - widget.style.headerSize);

          DateTime newStartTime = widget.date.add(calculateOffsetHourMinute(correctedOffset).asDuration);
          widget.dragAndDropOptions!.onEventDragged(details.data, newStartTime);
        },
      );
    }

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
  void onZoomFactorChanged(DayViewController controller, ScaleUpdateDetails details) {
    super.onZoomFactorChanged(controller, details);

    if (mounted) {
      setState(createEventsDrawProperties);
    }
  }

  @override
  DayViewStyle get currentDayViewStyle => widget.style;

  /// Creates the main widget, with a hours column and an events column.
  Widget createMainWidget() {
    List<Widget> children = [];

    if (widget.onBackgroundTappedDown != null) {
      children.add(Positioned.fill(
        child: GestureDetector(
          onTapUp: (details) {
            DateTime timeTapped = widget.date.add(calculateOffsetHourMinute(details.localPosition).asDuration);
            widget.onBackgroundTappedDown!(timeTapped);
          },
          child: Container(color: Colors.transparent),
        ),
      ));
    }

    children.addAll(eventsDrawProperties.entries.map((entry) => entry.value.createWidget(
          context,
          widget,
          buildResizeGestureDetector(entry.key),
          entry.key,
        )));

    if (widget.hoursColumnStyle.width > 0) {
      children.add(Positioned(
        top: 0,
        left: widget.isRTL ? null : 0,
        child: HoursColumn.fromHeadersWidgetState(parent: this),
      ));
    }

    if (Utils.sameDay(widget.date) && widget.minimumTime.atDate(widget.date).isBefore(DateTime.now()) && widget.maximumTime.atDate(widget.date).isAfter(DateTime.now())) {
      Widget? currentTimeIndicator =
          (widget.currentTimeIndicatorBuilder ?? DefaultBuilders.defaultCurrentTimeIndicatorBuilder)(widget.style, calculateTopOffset, widget.hoursColumnStyle.width, widget.isRTL);
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

  /// Builds a transparent GestureDetector widget to handle event resizing.
  Widget? buildResizeGestureDetector(FlutterWeekViewEvent event) {
    if (widget.resizeEventOptions == null) {
      return null;
    }

    return GestureDetector(
      onVerticalDragStart: (_) {
        accumulatedResizeOffset = 0;
        originalResizeEventEnd = event.end;
      },
      onVerticalDragEnd: (_) {
        // We restore the original event.end in order to pass the unchanged
        // event in the callback.
        DateTime newEventEnd = event.end;
        event.end = originalResizeEventEnd;
        setState(() {
          reset();
          createEventsDrawProperties();
        });
        widget.resizeEventOptions!.onEventResized(event, newEventEnd);
      },
      onVerticalDragUpdate: (details) => onEventResizeUpdate(event, details.primaryDelta ?? 0),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeUpDown,
        child: Container(color: Colors.transparent),
      ),
    );
  }

  /// Handles the updates of the event's resizing, by updating the UI to give
  /// realtime feedback of the event's new duration.
  void onEventResizeUpdate(FlutterWeekViewEvent event, double resizeOffset) {
    accumulatedResizeOffset += resizeOffset;

    // Compute the Duration equivalent to the accumulated offset.
    double hourRowHeight = calculateTopOffset(widget.minimumTime.add(const HourMinute(hour: 1)));
    double hourMinutesInHour = accumulatedResizeOffset / hourRowHeight;
    int hour = hourMinutesInHour.floor();
    int minute = ((hourMinutesInHour - hour) * 60).round();
    Duration delta = Duration(hours: hour, minutes: minute);

    // To prevent a user from decreasing the size of an event indefinitely,
    // we check if the new duration will be shorter than a minimum allowed
    // event duration.
    Duration newEventDuration = originalResizeEventEnd.add(delta).difference(event.start);
    Duration minimumDuration = widget.resizeEventOptions!.minimumEventDuration;

    // We also handle the (rare) case where the event's duration was originally
    // shorter than the allowed minimum duration. This is to avoid that, upon
    // the beginning of resizing the short event, it already grows to be as
    // long as the minimum duration.
    Duration originalEventDuration = originalResizeEventEnd.difference(event.start);
    if (minimumDuration > originalEventDuration) {
      minimumDuration = originalEventDuration;
    }

    // If the new duration is too short, we set the duration to be the minimum allowed.
    if (newEventDuration < minimumDuration) {
      event.end = event.start.add(minimumDuration);
    } else {
      // Otherwise, we compute the new event end normally.
      DateTime newEventEnd = originalResizeEventEnd.add(delta);
      Duration gridGranularity = widget.resizeEventOptions!.snapToGridGranularity;
      if (gridGranularity > Duration.zero) {
        newEventEnd = roundTimeToFitGrid(newEventEnd, gridGranularity: gridGranularity);
      }
      event.end = newEventEnd;
    }

    setState(() {
      reset();
      createEventsDrawProperties();
    });
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
      EventDrawProperties drawProperties = eventsDrawProperties[event] ?? EventDrawProperties(widget, event, widget.isRTL);
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
      double eventsColumnWidth = (context.findRenderObject() as RenderBox).size.width - widget.hoursColumnStyle.width;
      eventsGrid.processEvents(widget.hoursColumnStyle.width, eventsColumnWidth);
    }
  }
}
