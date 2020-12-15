import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/controller/day_view.dart';
import 'package:flutter_week_view/src/week_event.dart';
import 'package:flutter_week_view/src/styles/day_bar.dart';
import 'package:flutter_week_view/src/styles/day_view.dart';
import 'package:flutter_week_view/src/styles/hours_column.dart';
import 'package:flutter_week_view/src/utils/builders.dart';
import 'package:flutter_week_view/src/utils/event_grid.dart';
import 'package:flutter_week_view/src/utils/hour_minute.dart';
import 'package:flutter_week_view/src/utils/scroll.dart';
import 'package:flutter_week_view/src/utils/utils.dart';
import 'package:flutter_week_view/src/widgets/hours_column.dart';
import 'package:flutter_week_view/src/widgets/week_bar.dart';
import 'package:flutter_week_view/src/widgets/zoomable_header_widget.dart';

/// A (scrollable) day view which is able to display events, zoom and un-zoom and more !
class FullWeekView
    extends ZoomableHeadersWidget<DayViewStyle, DayViewController> {
  /// The events.
  final List<WeekEvent> events;

  /// The day view date.
  final DateTime date;

  /// The day bar style.
  final DayBarStyle dayBarStyle;

  /// Creates a new day view instance.
  FullWeekView({
    List<WeekEvent> events,
    @required DateTime date,
    DayViewStyle style,
    HoursColumnStyle hoursColumnStyle,
    DayBarStyle dayBarStyle,
    DayViewController controller,
    bool inScrollableWidget,
    HourMinute minimumTime,
    HourMinute maximumTime,
    HourMinute initialTime,
    bool userZoomable,
    CurrentTimeIndicatorBuilder currentTimeIndicatorBuilder,
    HoursColumnTimeBuilder hoursColumnTimeBuilder,
    HoursColumnTapCallback onHoursColumnTappedDown,
    DayBarTapCallback onDayBarTappedDown,
  })  : assert(date != null),
        date = date.yearMonthDay,
        events = events ?? [],
        dayBarStyle = dayBarStyle ?? DayBarStyle.fromDate(date: date),
        super(
          style: style ?? DayViewStyle.fromDate(date: date),
          hoursColumnStyle: hoursColumnStyle ?? const HoursColumnStyle(),
          controller: controller ?? DayViewController(),
          inScrollableWidget: inScrollableWidget ?? true,
          minimumTime: minimumTime ?? HourMinute.MIN,
          maximumTime: maximumTime ?? HourMinute.MAX,
          initialTime: initialTime?.atDate(date) ??
              (Utils.sameDay(date) ? HourMinute.now() : const HourMinute())
                  .atDate(date),
          userZoomable: userZoomable ?? true,
          hoursColumnTimeBuilder: hoursColumnTimeBuilder ??
              DefaultBuilders.defaultHoursColumnTimeBuilder,
          currentTimeIndicatorBuilder: currentTimeIndicatorBuilder ??
              DefaultBuilders.defaultCurrentTimeIndicatorBuilder,
          onHoursColumnTappedDown: onHoursColumnTappedDown,
          onDayBarTappedDown: onDayBarTappedDown,
        );

  @override
  State<StatefulWidget> createState() => _FullWeekViewState();
}

/// The day view state.
class _FullWeekViewState extends ZoomableHeadersWidgetState<FullWeekView> {
  /// Contains all events draw properties.
  // final Map<WeekEvent, EventDrawProperties> eventsDrawProperties =
  //     HashMap();

  /// The flutter week view events.
  // List<WeekEvent> events;

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
  void didUpdateWidget(FullWeekView oldWidget) {
    super.didUpdateWidget(oldWidget);
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
            left: widget.hoursColumnStyle.width,
            right: 0,
            child: WeekBar.fromHeadersWidgetState(
              parent: widget,
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
      onScaleStart: (_) => widget.controller.scaleStart(),
      onScaleUpdate: widget.controller.scaleUpdate,
      onVerticalDragStart: (detail) => {print(detail.localPosition.dx)},
      onVerticalDragEnd: (detail) => {print('end')},
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

  Widget weekBuilder() {
    final dragWidth =
        MediaQuery.of(context).size.width - widget.hoursColumnStyle.width;
    final eventWidth = dragWidth / 7;
    final children = widget.events
        .map((entry) {
          final timeStartObj =
              HourMinute(hour: entry.start.hour, minute: entry.start.minute);
          final timeEndObj =
              HourMinute(hour: entry.end.hour, minute: entry.end.minute);
          return entry.day
              .map((e) => Positioned(
                    top: calculateTopOffset(timeStartObj),
                    left: e * eventWidth,
                    child: Container(
                      width: eventWidth,
                      height: calculateTopOffset(timeEndObj) -
                          calculateTopOffset(timeStartObj),
                      child: entry.child,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xffcdebef), Color(0xff40798d)],
                          ),
                          border: Border.all(
                              color: const Color(0xffd8eaf3), width: 0.5)),
                    ),
                  ))
              .toList();
        })
        .toList()
        .expand((element) => element)
        .toList();
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            color: const Color.fromRGBO(240, 247, 250, 1),
            child: Stack(
              children: children,
            ),
          ),
        )
      ],
    );
  }

  /// Creates the main widget, with a hours column and an events column.
  Widget createMainWidget() {
    List<Widget> children = [];

    children.add(Padding(
      padding: EdgeInsets.only(left: widget.hoursColumnStyle.width),
      child: weekBuilder(),
    ));

    if (widget.hoursColumnStyle.width > 0) {
      children.add(Positioned(
        top: 0,
        left: 0,
        child: HoursColumn.fromHeadersWidgetState(parent: this),
      ));
    }

    Widget mainWidget = SizedBox(
      height: calculateHeight(),
      child: Stack(children: children),
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

  void reset() {
    // eventsDrawProperties.clear();
    // events = List.of(widget.events)..sort();
  }

  /// Creates the events draw properties and add them to the current list.
  void createEventsDrawProperties() {
    EventGrid eventsGrid = EventGrid();
    // for (WeekEvent event in List.of(events)) {
    //   EventDrawProperties drawProperties =
    //       eventsDrawProperties[event] ?? EventDrawProperties(widget, event);
    //   if (!drawProperties.shouldDraw) {
    //     events.remove(event);
    //     continue;
    //   }

    //   drawProperties.calculateTopAndHeight(calculateTopOffset);
    //   if (drawProperties.left == null || drawProperties.width == null) {
    //     eventsGrid.add(drawProperties);
    //   }

    //   eventsDrawProperties[event] = drawProperties;
    // }

    if (eventsGrid.drawPropertiesList.isNotEmpty) {
      double eventsColumnWidth =
          (context.findRenderObject() as RenderBox).size.width -
              widget.hoursColumnStyle.width;
      eventsGrid.processEvents(
          widget.hoursColumnStyle.width, eventsColumnWidth);
    }
  }
}
